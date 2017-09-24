class window.AlbumForm
  constructor: ($ele) ->
    @$ele = $ele
              .data('album-form-initialized', true)
              .on('click', '.photo .remove', (e) => @onPhotoRemove(e))
    @attachable = @$ele.data('attachable')
    @$form = $ele.parents('form')
    @$selectButton = $ele.find('.album-photo-upload').on('click', (e) => @selectFiles(e))
    @$files = $ele.find('.album-photos').on('change', (e) => @onFilesChanged(e))
    @$photos = $ele.find('.photos')
    @maxPhotos = @$photos.data('max-photos') || 10
    @maxSize = 1024 * 1024 * 10 # 10 MB
    @uploader = new Evaporate
      signerUrl: @$files.data('s3-signer')
      aws_key: @$files.data('s3-key')
      aws_url: @$files.data('s3-host')
      bucket: @$files.data('s3-bucket')
    @sortablePhotos()
    @updateButtonText()

  selectFiles: (e) ->
    e.preventDefault()
    @$files.click()

  validateFile: (file) ->
    validSize = file.size < @maxSize
    validType = /image\//.test(file.type)
    if validSize && validType
      return true
    else if !validSize
      error = "#{file.name} is too big, maximum is #{@maxSize / 1048576} MB"
    else if !validType
      error = "#{file.name} is not a valid image file"
    alert error
    false

  updateButtonText: ->
    total = @$ele.find('.photo.has-photo').length
    if @maxPhotos == 1
      text = 'Add Photo'
    else
      text = if total == 0 then 'Add Photos' else 'Add More Photos'
    @$selectButton.text(text)

  sortablePhotos: ->
    Sortable.create(
      @$ele.find('.photos ul.sortable')[0]
      draggable: '.has-photo'
      onSort: => @updatePhotoIndexes()
    )

  updatePhotoIndexes: ->
    $('.photo .index', @$ele).each (i) -> $(this).html i + 1
    $('.photo', @$ele).each (i) -> $(this).find('input.sorting').val(i)

    url = $('.photos', @$ele).data('sort-url')
    return unless url
    sorting = $.makeArray($('.photos .photo.has-photo', @$ele).map((i, e) -> $(e).data('id')))
    $.ajax
      url: url
      method: 'POST'
      data:
        sorting: sorting

  onFilesChanged: (e) ->
    start = @$ele.find('.photo.has-photo').length
    total = start + e.target.files.length

    if total > @maxPhotos
      alert "You can only add up to #{@maxPhotos} total photo(s)"
      return

    @disableButton() if total == @maxPhotos

    _this = this
    $.each e.target.files, (i) ->
      file = this
      $photo = _this.$ele.find(".photo:nth-child(#{start + i + 1})")
      unless _this.validateFile(file)
        _this.updateButtonText()
        i -= 1 # So next file is on proper slot in thumbnail list
        return

      $photo.addClass('uploading').attr('data-progress', '0%')

      imageId = randomHex()
      _this.uploader.add
        name: "#{_this.$files.data('prefix')}/#{imageId}"
        file: file
        notSignedHeadersAtInitiate: 'Cache-Control': 'max-age=3600'
        xAmzHeadersAtInitiate: 'x-amz-acl': 'public-read'
        beforeSigner: (xhr) ->
          requestDate = (new Date()).toISOString()
          xhr.setRequestHeader 'Request-Header', requestDate
        progress: (progress) ->
          progress = parseInt(progress * 100, 10) + '%'
          $photo.attr 'data-progress', progress
        complete: (xhr) ->
          imageUrl = xhr.responseURL.replace(/\?.+/, '')
          if _this.$photos.data('create-url')
            $.ajax
              url: _this.$photos.data('create-url'),
              method: 'POST'
              data: { photo: { image_id: imageId, image_content_type: file.type, image_size: file.size, image_filename: file.name } }
              success: (data) ->
                $photo.find('.img').css('background-image', "url(#{imageUrl})")
                $photo.removeClass('uploading').addClass('has-photo').attr('data-id', data.id)
                _this.updateButtonText()
          else
            $photo.find('.img').css('background-image', "url(#{imageUrl})")
            randomId = Math.random().toString().substr(2, 100)
            $photo
              .removeClass('uploading')
              .addClass('has-photo')
              .append("<input type='hidden' name='#{_this.attachable}[photos_attributes][#{randomId}][image_id]' value='#{imageId}'>")
              .append("<input type='hidden' name='#{_this.attachable}[photos_attributes][#{randomId}][image_content_type]' value='#{file.type}'>")
              .append("<input type='hidden' name='#{_this.attachable}[photos_attributes][#{randomId}][image_size]' value='#{file.size}'>")
              .append("<input type='hidden' name='#{_this.attachable}[photos_attributes][#{randomId}][image_filename]' value='#{file.name}'>")
              .append("<input type='hidden' class='sorting' name='#{_this.attachable}[photos][#{randomId}][sorting]' value='#{start + i}'>")

            _this.updateButtonText()

    _this.$files.wrap('<form>').closest('form').get(0).reset()
    _this.$files.unwrap()
    e.stopPropagation()
    e.preventDefault()

  removePhoto: ($photo) ->
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

  onPhotoRemove: (e) ->
    return unless confirm('Are you sure?')

    $this = $(e.target)
    $photo = $this.parents('.photo')

    return @removePhoto($photo) unless $photo.data('id')

    url = @$photos.data('update-url').replace('_ID_', $photo.data('id'))
    $.ajax
      url: url,
      method: 'DELETE'
      success: => @removePhoto $photo

  enableButton: -> @$selectButton.removeClass('disabled')
  disableButton: -> @$selectButton.addClass('disabled')
