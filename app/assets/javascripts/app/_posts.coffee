$ ->
  $form = $('.post-form')
  $photoButton = $form.find('.post__photo-btn')
  $photoAlbumBtn = $form.find('.post__album-btn')
  $photoInput = $form.find('#post_photo')

  $photoButton.click (e) ->
    e.preventDefault()
    $form.find('.tab-content .tab-pane').removeClass('active')
    $photoInput.click()

  $photoAlbumBtn.click (e) ->
    e.preventDefault()
    $form.find('.tab-content .tab-pane').removeClass('active')
    $($(this).attr('href')).addClass('active')

  $photoInput.change (e) ->
    file = e.target.files[0]
    if file && file.name
      $photoButton.text('Change Photo')
      $photoAlbumBtn.hide()
      $('#post__album').removeClass('active')
    else
      $photoButton.text('Add Photo')
      $photoAlbumBtn.show()

  $viewer = $('#post-viewer').modal(show: false)
  $('#explore-posts').on 'click', '.post a', (e) ->
    e.preventDefault()
    $viewer.modal('show')
    $body = $viewer.find('.modal-body').html('Loading...')
    $.getJSON $(this).attr('href'), (data) ->
      $body.html data.html
      initializeMentions $body
