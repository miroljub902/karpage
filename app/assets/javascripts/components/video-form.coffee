class window.VideoForm
  constructor: ($ele) ->
    @$ele = $ele
      .data('video-form-initialized', true)
      .on('click', '.photo .remove', (e) => @onVideoRemove(e))
    @attachable = @$ele.data('attachable')
    @$form = $ele.parents('form')

    @$selectButton = $ele.find('.video-form__btn').on('click', (e) => @selectFiles(e))
    @$file = $ele.find('.video-form__input').on('change', (e) => @onFileChanged(e))
    @$video = $ele.find('.video-form__video video')
    @maxSize = $ele.data('max-size')
    @uploader = new Evaporate
      signerUrl: @$file.data('s3-signer')
      aws_key: @$file.data('s3-key')
      aws_url: @$file.data('s3-host')
      bucket: @$file.data('s3-bucket')
    @updateButtonText()

  selectFiles: (e) ->
    e.preventDefault()
    @$file.click()

  validateFile: (file) ->
    validSize = file.size < @maxSize
    validType = /video\//.test(file.type)
    if validSize && validType
      return true
    else if !validSize
      error = "#{file.name} is too big, maximum is #{@maxSize / 1048576} MB"
    else if !validType
      error = "#{file.name} is not a valid video file"
    alert error
    false

  updateButtonText: ->
    text = if @hasVideo() then @$selectButton.data('update-label') else @$selectButton.data('create-label')
    @$selectButton.html(text)

  updatePreview: (file) ->
    console.log file
    @$video.find('source')
      .attr 'src', URL.createObjectURL(file)
      .end()
      .get(0).load()

  hasVideo: ->
    @$ele.find('.video-form__video--present').length > 0

  onFileChanged: (e) ->
    _this = this
    $.each e.target.files, (i) ->
      file = this
      return _this.updateButtonText() unless _this.validateFile(file)

      _this.$ele.addClass('video-form--uploading').attr('data-progress', '0%')
      _this.$selectButton.attr 'data-progress', "Uploading... (0%)"
      _this.disableButton()

      videoId = randomHex()
      _this.uploader.add
        name: "#{_this.$file.data('prefix')}/#{videoId}"
        file: file
        notSignedHeadersAtInitiate:
          'Cache-Control': 'max-age=3600'
        xAmzHeadersAtInitiate:
          'x-amz-acl': 'public-read'
        beforeSigner: (xhr) ->
          requestDate = (new Date()).toISOString()
          xhr.setRequestHeader 'Request-Header', requestDate
        progress: (progress) ->
          progress = parseInt(progress * 100, 10) + '%'
          _this.$selectButton.attr 'data-progress', "Uploading... (#{progress})"
        complete: (xhr) ->
          videoUrl = xhr.responseURL.replace(/\?.+/, '')
          $.ajax
            url: _this.$ele.data('create-url'),
            method: 'POST'
            data: {
              video: {
                source_id: videoId,
                source_filename: file.name
              }
            }
            success: (data) ->
              _this.$ele.removeClass('video-form--uploading').addClass('video-form__video--present')
              _this.enableButton()
              _this.updateButtonText()
              _this.updatePreview file

    _this.$file.wrap('<form>').closest('form').get(0).reset()
    _this.$file.unwrap()
    e.stopPropagation()
    e.preventDefault()

  removeVideo: ($photo) ->
    $photo.find('input[type=hidden]').remove()
    @enableButton()
    $parent = $photo.parent()
    $photo.fadeOut =>
      $photo
        .removeClass('has-photo')
        .removeAttr('data-id')
        .find('.img')
        .removeAttr('style')
        .end()
        .detach()
        .appendTo($parent)
        .fadeIn()

      @updatePhotoIndexes()
      @updateButtonText()

  onVideoRemove: (e) ->
    return unless confirm('Are you sure?')

    $this = $(e.target)
    $photo = $this.parents('.photo')

    return @removeVideo($photo) unless $photo.data('id')

    url = @$photos.data('update-url').replace('_ID_', $photo.data('id'))
    $.ajax
      url: url,
      method: 'DELETE'
      success: => @removeVideo $photo

  enableButton: ->
    @$selectButton.removeClass('disabled')

  disableButton: ->
    @$selectButton.addClass('disabled')
