<% if @user.errors.any? %>
$modal = $('#modalSignUp')
$content = $("<%= escape_javascript(render('users/signup')) %>").find('.modal-content')
$('.modal-content', $modal).replaceWith $content
$modal.modal('handleUpdate')
<% else %>
window.location.reload()
<% end %>
