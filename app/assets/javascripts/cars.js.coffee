$ ->
  $(document).on 'click', '.car-photo-upload', (e) ->
    e.preventDefault()
    $container = $(this).parents('.photos')
    $files = $(this).parent().find('.car-photos').click()

    uploader = new Evaporate
      signerUrl: $files.data('s3-signer')
      aws_key: $files.data('s3-key')
      aws_url: $files.data('s3-host')
      bucket: $files.data('s3-bucket')

    $files.change (e) ->
      # TODO:
      # - Check not more than 10 - existing photos
      # - Disable button while uploading
      # - Disable button when full
      # - Clear file input after uploading

      start = 0 # TODO
      $.each e.target.files, (i) ->
        $photo = $(".photo:nth-child(#{start + i + 1})", $container)
        $photo.addClass('uploading').attr('data-progress', '0%')

        uploader.add
          name: "#{$files.data('prefix')}/#{this.name}"
          file: this
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
            $container.find(".photo-url[data-index=#{i + 1}]").val imageUrl
            $photo.find('.img').css('background-image', "url(#{imageUrl})")
            $photo.removeClass('uploading').addClass('has-photo')
