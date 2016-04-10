$ ->
  $form = $('.post-form')
  $photoButton = $form.find('.photobutton')
  $photoInput = $form.find('#post_photo')

  $photoButton.click (e) ->
    e.preventDefault()
    $photoInput.click()

  $photoInput.change (e) ->
    file = e.target.files[0]
    $text = $photoButton.find('.text')
    if file && file.name
      $text.html('Change Photo')
    else
      $text.html('Add Photo')

  $viewer = $('#post-viewer').modal(show: false)
  $('#explore-posts .post a').click (e) ->
    e.preventDefault()
    $viewer.modal('show')
    $body = $viewer.find('.modal-body').html('Loading...')
    $.getJSON $(this).attr('href'), (data) -> $body.html data.html
