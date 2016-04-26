$ ->
  $userProfile = $('.user-profile')
  $edit = $('.edit', $userProfile)
  $editing = $('.editing', $userProfile)
  $avatar = $('.avatar-container', $userProfile)
  $avatarInput = $('.avatar-input', $userProfile)
  $avatarInput.data 'original', $avatar.find('img').attr('src')
  $background = $userProfile.parents('.jumbo-header')
  $changeBackground = $('.change-background', $userProfile)
  $backgroundInput = $('input.background-photo', $userProfile)
  $backgroundInput.data 'original', $background.css('backgroundImage')

  $editables = $('.editable', $userProfile)
  $location = $('.location', $userProfile)
  $description = $('.description', $userProfile)
  $link = $('.link', $userProfile)

  $location.data('original', $location.html())
  $description.data('original', $description.html())
  $link.data('original', $link.html())

  startEditing = ->
    options = { emptytext: ' ' }
    $userProfile.addClass('editing').parents('.jumbo-header').addClass('editing')

    $location.editable(options)
    $description.editable(options)

    linkDisplay = (value) ->
      link = value.trim()
      if link.length == 0 then $(this).html('') else $(this).html "<a href='#{link}'>#{link}</a>"

    $link.editable($.extend(display: linkDisplay, options))

  saveEdits = ->
    link = if $link.find('a').length > 0 then $link.find('a').html().trim() else ''
    data =
      location: $location.html().trim()
      description: $description.html().trim()
      link: link
      avatar_crop_params: $cropParams.val()
      profile_background_crop_params: $cropParamsBg.val()
    if $backgroundInput.data('attachment')
      data.profile_background_id = $backgroundInput.data('attachment').id
      data.profile_background_content_type = $backgroundInput.data('attachment').contentType
      data.profile_background_size = $backgroundInput.data('attachment').size
      data.profile_background_filename = $backgroundInput.data('attachment').filename
    if $avatarInput.data('attachment')
      data.avatar_id = $avatarInput.data('attachment').id
      data.avatar_content_type = $avatarInput.data('attachment').contentType
      data.avatar_size = $avatarInput.data('attachment').size
      data.avatar_filename = $avatarInput.data('attachment').filename
    $.ajax
      url: '/user'
      dataType: 'json'
      method: 'put'
      data: { user: data }
      error: (xhr) ->
        unless xhr.responseJSON
          alert 'Unexpected error, please try again later.'
          return

        if xhr.responseJSON['location']
          errors = xhr.responseJSON['location'][0]
          $location.addClass('error').tooltip(title: errors, trigger: 'manual', placement: 'right').tooltip('show')
        if xhr.responseJSON['description']
          errors = xhr.responseJSON['description'][0]
          $description.addClass('error').tooltip(title: errors, trigger: 'manual', placement: 'right').tooltip('show')
        if xhr.responseJSON['link']
          errors = xhr.responseJSON['link'][0]
          $link.addClass('error').tooltip(title: errors, trigger: 'manual', placement: 'right').tooltip('show')
        if xhr.responseJSON['profile_background_id']
          errors = xhr.responseJSON['profile_background_id'][0]
          alert errors
        if xhr.responseJSON['avatar_id']
          errors = xhr.responseJSON['avatar_id'][0]
          alert errors

      success: ->
        $userProfile.removeClass('editing').parents('.jumbo-header').removeClass('editing')
        $backgroundInput.data('attachment', {}).data('original', $background.css('backgroundImage'))
        $avatarInput.data('attachment', {}).data('original', $avatar.find('img').attr('src'))
        $editables.editable('destroy').addClass('editable').removeClass('error').tooltip('destroy').each ->
          $this = $(this)
          $this.data('original', $this.html()).removeAttr('style')
        $avatar.removeClass 'editing'
        $editing.fadeOut -> $edit.fadeIn()

  cancelEdits = ->
    $userProfile.removeClass('editing').parents('.jumbo-header').removeClass('editing')
    $backgroundInput.data('attachment', {}).val('')
    $editables.editable('destroy').addClass('editable').removeClass('error').tooltip('destroy').each ->
      $this = $(this)
      $this.html($this.data('original')).removeAttr('style')
    $background.css('backgroundImage', $backgroundInput.data('original'))
    $avatarInput.val('')
    if $avatarInput.data('original')
      $avatar.find('img').attr('src', $avatarInput.data('original'))
    else
      $avatar.find('img').remove()

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
        $backgroundInput.data 'attachment',
          id: imageId
          contentType: file.type
          size: file.size
          filename: file.name
        imageUrl = xhr.responseURL.replace(/\?.+/, '')
        $background.css('backgroundImage', "url(#{imageUrl})")
        $changeBackground.removeClass('disabled').html($changeBackground.data('original'))
        cropBackground imageUrl
      error: ->
        alert 'Could not upload your background image, please try again later.'

  $cropModalBg = $('#crop-background')
  $cropBg = $cropModalBg.find('.cropper-container')
  $cropParamsBg = $('#user_profile_background_crop_params')
  $cropModalBg.on 'shown.bs.modal', ->
    unless $cropBg.data('initialized')
      $cropBg.croppie
        url: $cropBg.data('src')
        boundary:
          width: 500
          height: 300
        viewport:
          width: 300
          height: 180
          type: 'square'
    $cropBg.data 'initialized', true

  $cropModalBg.find('.js-save').click (e) ->
    points = $cropBg.croppie('get').points
    x = points[0]
    y = points[1]
    width = points[2] - x
    height = points[3] - y
    $cropParamsBg.val "#{x},#{y},#{width},#{height}"
    imgUrl = $cropBg.find('.cr-image').attr('src') + "?rect=#{$cropParamsBg.val()}"
    $background.css('backgroundImage', "url(#{imgUrl})")
    $cropModalBg.modal('hide')

  cropBackground = (url) ->
    path = url.match(/amazonaws.com\/.+?\/(.*)/)[1]
    $cropBg.attr 'data-src', "//#{$cropBg.data('asset-host')}/#{path}"
    $cropModalBg.modal('show')

  $cropModal = $('#crop-avatar')
  $crop = $cropModal.find('.cropper-container')
  $cropParams = $('#user_avatar_crop_params')
  $cropModal.on 'shown.bs.modal', ->
    unless $crop.data('initialized')
      $crop.croppie
        url: $crop.data('src')
        boundary:
          width: 300
          height: 300
        viewport:
          width: 200
          height: 200
          type: 'circle'
    $crop.data 'initialized', true

  $cropModal.find('.js-save').click (e) ->
    points = $crop.croppie('get').points
    x = points[0]
    y = points[1]
    width = points[2] - x
    height = points[3] - y
    $cropParams.val "#{x},#{y},#{width},#{height}"
    $img = $avatar.find('img')
    $img.attr 'src', $crop.find('.cr-image').attr('src') + "?rect=#{$cropParams.val()}"
    $cropModal.modal('hide')

  cropAvatar = (url) ->
    path = url.match(/amazonaws.com\/.+?\/(.*)/)[1]
    $crop.attr 'data-src', "//#{$crop.data('asset-host')}/#{path}"
    $cropModal.modal('show')

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
        $avatarInput.data 'attachment',
          id: imageId
          contentType: file.type
          size: file.size
          filename: file.name
        imageUrl = xhr.responseURL.replace(/\?.+/, '')
        $img = $avatar.find('img')
        if $img.length > 0
          $img.attr 'src', imageUrl
        else
          $avatar.append("<img src='#{imageUrl}' width='150' height='150' class='avatar'>")
        $avatar.attr 'data-edit', $avatar.data('edit-original')
        cropAvatar imageUrl
      error: ->
        alert 'Could not upload your avatar, please try again later.'

  $('.user-profile .edit-profile').click (e) ->
    e.preventDefault()
    $edit.fadeOut ->
      $avatar.addClass 'editing'
      $editing.fadeIn()
      startEditing()

  $('.user-profile .save').click (e) ->
    e.preventDefault()
    saveEdits()

  $('.user-profile .close-edit').click (e) ->
    e.preventDefault()
    $avatar.removeClass 'editing'
    cancelEdits()
    $editing.fadeOut ->
      $edit.fadeIn()
