randomHex = ->
  part = -> Math.floor((1 + Math.random()) * 0x100000).toString(16)
  "#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}#{part()}"

$ ->
  $selectButton = null
  enableButton = -> $selectButton.removeClass('disabled')
  disableButton = -> $selectButton.addClass('disabled')

  $(document).on 'click', '.photo .remove', (e) ->
    $this = $(this)
    $photo = $this.parents('.photo')
    $photos = $this.parents('.photos')
    $selectButton ||= $('.car-photo-upload', $photos)
    url = $photos.data('update-url').replace('_ID_', $photo.data('id'))
    $.ajax
      url: url,
      method: 'DELETE'
      success: ->
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
          $('.photo .index', $parent).each (i) ->
            $(this).html i + 1

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
            $.ajax
              url: $photos.data('create-url'),
              method: 'POST'
              data: { photo: { image_id: image_id, image_content_type: file.type, image_size: file.size, image_filename: file.name } }
              success: (data) ->
                imageUrl = xhr.responseURL.replace(/\?.+/, '')
                $photos.find(".photo-url[data-index=#{i + 1}]").val imageUrl
                $photo.find('.img').css('background-image', "url(#{imageUrl})")
                $photo.removeClass('uploading').addClass('has-photo').attr('data-id', data.id)

      $files.wrap('<form>').closest('form').get(0).reset()
      $files.unwrap()
      $files.stopPropagation()
      $files.preventDefault()

    $files.click()
