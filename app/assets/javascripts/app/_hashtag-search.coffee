$ ->
  $form = $('.js-hashtag-search')
  $tag = $form.find('input.hashtag')

  $form.submit (e) ->
    e.preventDefault()
    window.location = "/hashtags/#{$tag.val()}/"
