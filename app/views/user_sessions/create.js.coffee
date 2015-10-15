<% if @user_session.errors.any? %>
  $modal = $('#modalSignIn')
  $content = $("<%= escape_javascript(render('user_sessions/signin')) %>").find('.modal-content')
  $('.modal-content', $modal).replaceWith $content
  $modal.modal('handleUpdate')
<% else %>
  window.location.reload()
<% end %>
