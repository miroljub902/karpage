$('.modal').modal('hide')

$modal = $('#modalSignUp')
$modal = $("<%= escape_javascript(render('users/signup')) %>") if $modal.length == 0
$modal.modal()
