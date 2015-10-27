$ ->
  $selectButton = null

  updateButtonText = ->
    total = $('.car-form .photo.has-photo').length
    text = if total == 0 then 'Add Photos' else 'Add More Photos'
    $selectButton.html(text)

  enableButton = -> $selectButton.removeClass('disabled')

  disableButton = -> $selectButton.addClass('disabled')

  updatePhotoIndexes = ->
    $modal = $('.car-form')
    $('.photo .index', $modal).each (i) -> $(this).html i + 1
    $('.photo', $modal).each (i) -> $(this).find('input.sorting').val(i)

    url = $('.photos', $modal).data('sort-url')
    return unless url
    sorting = $.makeArray($('.photos .photo.has-photo', $modal).map((i, e) -> $(e).data('id')))
    $.ajax
      url: url
      method: 'POST'
      data:
        sorting: sorting

  removePhoto = ($photo) ->
    $photo.find('input[type=hidden]').remove()
    enableButton()
    $parent = $photo.parent()
    $photo.fadeOut ->
      $photo
      .removeClass('has-photo')
      .removeAttr('data-id')
      .find('.img')
      .removeAttr('style')
      .end()
      .detach()
      .appendTo($parent)
      .fadeIn()

      updatePhotoIndexes()
      updateButtonText()

  # Reordering images
  # Cannot use the class name directly
  $(document).on 'show.bs.modal', (e) ->
    $modal = $(e.target)
    return unless $modal.hasClass('car-form')
    $photos = $modal.find('.photos')
    Sortable.create(
      $modal.find('.photos ul')[0]
      draggable: '.has-photo'
      onSort: updatePhotoIndexes
    )

  $(document).on 'click', '.photo .remove', (e) ->
    return unless confirm('Are you sure?')

    $this = $(this)
    $photo = $this.parents('.photo')
    $photos = $this.parents('.photos')
    $selectButton ||= $('.car-photo-upload', $photos)

    return removePhoto($photo) unless $photo.data('id')

    url = $photos.data('update-url').replace('_ID_', $photo.data('id'))
    $.ajax
      url: url,
      method: 'DELETE'
      success: ->
        removePhoto $photo

  $(document).on 'click', '.car-photo-upload', (e) ->
    e.preventDefault()
    $selectButton = $(this)
    $photos = $selectButton.parents('.photos')
    $files = $selectButton.parent().find('.car-photos')
    return $files.click() if $files.data('handled')
    $files.data 'handled', true

    uploader = new Evaporate
      signerUrl: $files.data('s3-signer')
      aws_key: $files.data('s3-key')
      aws_url: $files.data('s3-host')
      bucket: $files.data('s3-bucket')

    $files.change (e) ->
      start = $('.photo.has-photo', $photos).length
      total = start + e.target.files.length

      if total > 10
        alert 'You can only add up to 10 total photos'
        return

      disableButton() if total == 10

      $.each e.target.files, (i) ->
        file = this
        $photo = $(".photo:nth-child(#{start + i + 1})", $photos)
        $photo.addClass('uploading').attr('data-progress', '0%')

        image_id = randomHex()
        uploader.add
          name: "#{$files.data('prefix')}/#{image_id}"
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
            $photo.attr 'data-progress', progress
          complete: (xhr) ->
            imageUrl = xhr.responseURL.replace(/\?.+/, '')
            if $photos.data('create-url')
              $.ajax
                url: $photos.data('create-url'),
                method: 'POST'
                data: { photo: { image_id: image_id, image_content_type: file.type, image_size: file.size, image_filename: file.name } }
                success: (data) ->
                  $photo.find('.img').css('background-image', "url(#{imageUrl})")
                  $photo.removeClass('uploading').addClass('has-photo').attr('data-id', data.id)
                  updateButtonText()
            else
              $photo.find('.img').css('background-image', "url(#{imageUrl})")
              randomId = Math.random().toString().substr(2, 100)
              $photo
                .removeClass('uploading')
                .addClass('has-photo')
                .append('<input type="hidden" name="car[photos_attributes][' + randomId + '][image_id]" value="' + image_id + '">')
                .append('<input type="hidden" name="car[photos_attributes][' + randomId + '][image_content_type]" value="' + file.type + '">')
                .append('<input type="hidden" name="car[photos_attributes][' + randomId + '][image_size]" value="' + file.size + '">')
                .append('<input type="hidden" name="car[photos_attributes][' + randomId + '][image_filename]" value="' + file.name + '">')
                .append('<input type="hidden" class="sorting" name="car[photos][' + randomId + '][sorting]" value="' + (start + i) + '">')

              updateButtonText()

      $files.wrap('<form>').closest('form').get(0).reset()
      $files.unwrap()
      $files.stopPropagation()
      $files.preventDefault()

    $files.click()
