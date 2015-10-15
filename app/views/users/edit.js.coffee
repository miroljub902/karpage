$('.modal').modal('hide')

$modal = $('#modalAccount')
$modal = $("<%= escape_javascript(render('users/account')) %>") if $modal.length == 0
$modal.modal()
