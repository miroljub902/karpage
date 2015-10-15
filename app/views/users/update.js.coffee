<% if @user.errors.any? %>
$modal = $('#modalAccount')
$content = $("<%= escape_javascript(render('users/account')) %>").find('.modal-content')
$('.modal-content', $modal).replaceWith $content
$modal.modal('handleUpdate')
<% else %>
window.location.reload()
<% end %>
