class window.VideoForm
  constructor: ($ele) ->
    @$ele = $ele.data('video-form-initialized', true)
    @attachable = @$ele.data('attachable')
    @$form = $ele.parents('form')

    @$selectButton = $ele.find('.video-form__btn').on('click', (e) => @selectFiles(e))
    @$removeButton = $ele.find('.video-form__remove .btn').on('click', (e) => @onRemoveVideo(e))
    @$file = $ele.find('.video-form__input').on('change', (e) => @onFileChanged(e))
    @$video = $ele.find('.video-form__video video')
    @$videoInput = $ele.find("##{@attachable}_video_attributes_source_id")
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
    @$video.parent().addClass('video-form__video--preview')
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
      _this.$video.parent().removeClass('video-form__video--complete')
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
          _this.$videoInput.val(videoId)
          _this.$ele.removeClass('video-form--uploading')
          _this.$video.parent().addClass('video-form__video--present')
          _this.$selectButton.hide()
          _this.updatePreview file

    _this.$file.wrap('<form>').closest('form').get(0).reset()
    _this.$file.unwrap()
    e.stopPropagation()
    e.preventDefault()

  resetForm: ->
    @$video.parent().removeClass('video-form__video--present video-form__video--preview video-form__video--complete')
    @updateButtonText()
    @enableButton()

  onRemoveVideo: (e) ->
    e.preventDefault()
    return unless confirm('Are you sure?')

    @disableButton()
    $this = $(e.target)
    $.ajax
      url: $this.data('url')
      method: 'DELETE'
      success: =>
        @$video.find('source').removeAttr('src')
        @resetForm()
      error: =>
        alert('There was an unexpected error. Please try again later.')

  enableButton: ->
    @$selectButton.removeClass('disabled').show()

  disableButton: ->
    @$selectButton.addClass('disabled')
