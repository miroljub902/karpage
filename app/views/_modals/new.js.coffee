$newModal = $("<%= escape_javascript(render(content, (options ||= {}))) %>")
# Have to re-trigger it so other scripts catch it
singleTrigger = ->
  $newModal.off 'show.bs.modal', singleTrigger
  $newModal.trigger 'show.bs.modal'
$newModal.on 'show.bs.modal', singleTrigger

$modal = $('#<%= id %>')
if $modal.length == 0
  show = ->
    $newModal.modal('show')
    singleTrigger()
else
  show = ->
    $('.modal-content', $modal).replaceWith $newModal.find('.modal-content')
    $modal.modal('show') unless $modal.is(':visible')
    $modal.trigger 'show.bs.modal'
    $modal.modal('handleUpdate')

$other = $('.modal').not('#<%= id %>')
if $other.length > 0
  if $other.is(':visible')
    show_and_unbind = ->
      show()
      $other.modal('hide').off 'hidden.bs.modal', show_and_unbind

    $other.modal('hide').on 'hidden.bs.modal', show_and_unbind
  else
    show()
else
  show()
