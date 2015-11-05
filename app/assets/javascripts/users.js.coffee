$ ->
  $userProfile = $('.user-profile')
  $edit = $('.edit', $userProfile)
  $editing = $('.editing', $userProfile)
  $avatar = $('.avatar-container', $userProfile)
  $avatarInput = $('.avatar-input', $userProfile)
  $info = $('.edit-info', $userProfile)
  $background = $userProfile.parents('.jumbo-header')
  $changeBackground = $('.change-background', $userProfile)
  $backgroundInput = $('input.background-photo', $userProfile)

  userId = $userProfile.data('user-id')

  uploader = new Evaporate
    signerUrl: $backgroundInput.data('s3-signer')
    aws_key: $backgroundInput.data('s3-key')
    aws_url: $backgroundInput.data('s3-host')
    bucket: $backgroundInput.data('s3-bucket')

  $changeBackground.click (e) ->
    e.preventDefault()
    $backgroundInput.click()

  $backgroundInput.change (e) ->
    $changeBackground.addClass('disabled').data('original', $changeBackground.html()).html('Uploading...')
    file = e.target.files[0]
    imageId = randomHex()
    uploader.add
      name: "#{$backgroundInput.data('prefix')}/#{imageId}"
      file: file
      notSignedHeadersAtInitiate:
        'Cache-Control': 'max-age=3600'
      xAmzHeadersAtInitiate:
        'x-amz-acl': 'public-read'
      beforeSigner: (xhr) ->
        requestDate = (new Date()).toISOString()
        xhr.setRequestHeader 'Request-Header', requestDate
      complete: (xhr) ->
        imageUrl = xhr.responseURL.replace(/\?.+/, '')
        $.ajax
          url: $backgroundInput.data('update-url'),
          method: 'PUT'
          dataType: 'text' # Prevent returned code from executing
          data: { user: { profile_background_id: imageId, profile_background_content_type: file.type, profile_background_size: file.size, profile_background_filename: file.name } }
          success: (data) ->
            $background.css('backgroundImage', "url(#{imageUrl})")
            $changeBackground.removeClass('disabled').html($changeBackground.data('original'))
          error: ->
            alert 'Could not upload your background image, please try again later.'
      error: ->
        alert 'Could not upload your background image, please try again later.'

  $avatar.click (e) ->
    e.preventDefault()
    $avatarInput.click() if $avatar.hasClass('editing')

  $avatarInput.change (e) ->
    $avatar.data('edit-original', $avatar.attr('data-edit')).attr('data-edit', 'Uploading...')
    file = e.target.files[0]
    imageId = randomHex()
    uploader.add
      name: "#{$avatarInput.data('prefix')}/#{imageId}"
      file: file
      notSignedHeadersAtInitiate:
        'Cache-Control': 'max-age=3600'
      xAmzHeadersAtInitiate:
        'x-amz-acl': 'public-read'
      beforeSigner: (xhr) ->
        requestDate = (new Date()).toISOString()
        xhr.setRequestHeader 'Request-Header', requestDate
      complete: (xhr) ->
        imageUrl = xhr.responseURL.replace(/\?.+/, '')
        $.ajax
          url: $avatarInput.data('update-url'),
          method: 'PUT'
          dataType: 'text' # Prevent returned code from executing
          data: { user: { avatar_id: imageId, avatar_content_type: file.type, avatar_size: file.size, avatar_filename: file.name } }
          success: (data) ->
            $img = $avatar.find('img')
            if $img.length > 0
              $img.attr 'src', imageUrl
            else
              $avatar.append("<img src='#{imageUrl}' width='150' height='150' class='avatar'>")
            $avatar.attr 'data-edit', $avatar.data('edit-original')
          error: ->
            alert 'Could not upload your avatar, please try again later.'
      error: ->
        alert 'Could not upload your avatar, please try again later.'

  $('.user-profile .edit-profile').click (e) ->
    e.preventDefault()
    $edit.fadeOut ->
      $avatar.addClass 'editing'
      $editing.fadeIn()
      $info.fadeIn()

  $('.user-profile .close-edit').click (e) ->
    e.preventDefault()
    $avatar.removeClass 'editing'
    $info.fadeOut()
    $editing.fadeOut ->
      $edit.fadeIn()
