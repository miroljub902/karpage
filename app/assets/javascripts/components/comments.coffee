$form = $("""
<form class="new-comment js-thread-form clearfix m-t-3 collapse" data-commentable-type="Comment" accept-charset="UTF-8" data-remote="true" method="post">
  <input name="utf8" type="hidden" value="✓">
  <input type="hidden" name="return_to">
  <textarea class="form-control js-mentions" rows="6" name="comment[body]"></textarea>
  <input type="submit" name="commit" value="Reply" class="btn btn-green pull-right" data-disable-with="Reply">
</form>
""")

$(document).on 'click', '.js-thread-reply', (e) ->
  e.preventDefault()

  $this = $(this)
  id = $this.attr('data-comment-id')
  commentableId = $this.attr('data-commentable-id')
  mention = $this.attr('data-comment-author')
  mention = if mention.length > 0 then "@#{mention} " else ""

  $comment = $this.closest('.comment')
  $existing = $('.js-thread-form')
  $existing.remove()
  if $existing.length == 0 || $existing.attr('data-commentable-id') != id
    $form.get(0).reset()

    if $comment.parents('[data-photobutton]').length && $form.find('.comment-photobutton').length == 0
      $form.append """
        <div class="comment-photobutton pull-right">
          <input name="comment[photo]" type="file" accept="image/*"/>
          <div class="preview">
            <img/>
            <div class="remove sprite sprite-delete"></div>
          </div>
          <div class="comment-photobutton__btn">
            <div class="fa fa-photo"></div>
          </div>
        </div>
      """

    $form
      .attr('id', "comment-#{commentableId}__reply")
      .attr('data-commentable-id', id)
      .attr('action', "/comments/#{commentableId}/comments")
      .find('[name=return_to]')
        .attr('value', "/comments/#{commentableId}/comments")
        .end()
      .find('[name="comment[body]"]')
        .text(mention)
        .end()
      .insertAfter($comment)
      .addClass('in')
      .find('input[type=submit]').removeAttr('disabled').end()
      .find('[name="comment[body]"]')
        .focus()

    initializeMentions $form

$(document).on 'click', '.comment-photobutton img, .comment-photobutton__btn', (e) ->
  e.stopPropagation()
  $this = $(this)
  $btn = $this.closest('.comment-photobutton')
  $btn.find('input')
    .change (e) ->
      file = e.target.files[0]
      if file && file.name
        reader = new FileReader()
        reader.onload = (e) ->
          $btn.addClass('with-preview')
          $btn.find('img').attr('src', e.target.result).removeAttr('srcset')
        reader.readAsDataURL(file)
       else
        $btn.removeClass('with-preview')
    .click()

$(document).on 'reset', 'form.new-comment', (e) ->
  $(this)
    .find('.comment-photobutton').removeClass('with-preview').end()
    .find('input[type=file]').val('')

$(document).on 'click', '.comment-photobutton .remove', (e) ->
  e.stopPropagation()
  $this = $(this)
  $btn = $this.closest('.comment-photobutton')
  $btn.removeClass('with-preview')
  $btn.find('input').val('')
