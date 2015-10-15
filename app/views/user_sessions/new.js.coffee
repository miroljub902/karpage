$('.modal').modal('hide')

$modal = $('#modalSignIn')
$modal = $("<%= escape_javascript(render('user_sessions/signin')) %>") if $modal.length == 0
$modal.modal()
