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
  mention = $this.attr('data-comment-author')
  mention = if mention.length > 0 then "@#{mention} " else ""

  $existing = $('.js-thread-form')
  $existing.remove()
  if $existing.length == 0 || $existing.attr('data-commentable-id') != id
    $form
      .attr('id', "comment-#{id}__reply")
      .attr('data-commentable-id', id)
      .attr('action', "/comments/#{id}/comments")
      .find('[name=return_to]')
        .attr('value', "/comments/#{id}/comments")
        .end()
      .find('[name="comment[body]"]')
        .text(mention)
        .end()
      .insertAfter($this.closest('.comment'))
      .addClass('in')
      .find('[name="comment[body]"]')
        .focus()

    initializeMentions $form
