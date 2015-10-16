$newModal = $("<%= escape_javascript(render(content, (options ||= {}))) %>")

$modal = $('#<%= id %>')
if $modal.length == 0
  show = -> $newModal.modal('show')
else
  show = ->
    $('.modal-content', $modal).replaceWith $newModal.find('.modal-content')
    $modal.modal('show') unless $modal.is(':visible')
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
