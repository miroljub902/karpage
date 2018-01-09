$ ->
  $form = $('.post-form')
  $photoButton = $form.find('.post__photo-btn')
  $photoAlbumBtn = $form.find('.post__album-btn')
  $photoInput = $form.find('#post_photo')
  $preview = $form.find('.photobutton .preview')
  $btnContainer = $preview.closest('.photobutton-container')

  triggerFileInput = (e) ->
    e.preventDefault()
    e.stopPropagation()
    $form.find('.tab-content .tab-pane').removeClass('active')
    $photoInput.click()

  $photoButton.click triggerFileInput
  $preview.find('img').click triggerFileInput

  $photoAlbumBtn.click (e) ->
    e.preventDefault()
    $form.find('.tab-content .tab-pane').removeClass('active')
    $($(this).attr('href')).addClass('active')

  includeRemovePhotoField = ->
    $('<input type="hidden" name="post[remove_photo]" value="1"/>').appendTo($form)
  removeRemovePhotoField = ->
    $form.find('[name="post[remove_photo]"]').remove()

  $photoInput.change (e) ->
    file = e.target.files[0]
    if file && file.name
      $photoAlbumBtn.hide()
      $('#post__album').removeClass('active')

      reader = new FileReader()
      reader.onload = (e) ->
        $preview.parent().addClass('with-preview')
        $preview.find('img').attr('src', e.target.result)
      reader.readAsDataURL(file)
      removeRemovePhotoField()
    else
      $preview.parent().removeClass('with-preview')
      $photoButton.text('Add Photo')
      $photoAlbumBtn.show()
      includeRemovePhotoField()

  $preview.find('.remove').click (e) ->
    e.stopPropagation()
    includeRemovePhotoField()
    $photoInput.val('')
    $photoAlbumBtn.show()
    $preview.parent().removeClass('with-preview')
    $btnContainer.removeClass('single').addClass('dropdown')

  $viewer = $('#post-viewer').modal(show: false)
  $('.cards').on 'click', '.post-card a', (e) ->
    e.preventDefault()
    $viewer.modal('show')
    $body = $viewer.find('.modal-body').html('Loading...')
    $.getJSON $(this).attr('href'), (data) ->
      $body.html data.html
      initializeMentions $body
