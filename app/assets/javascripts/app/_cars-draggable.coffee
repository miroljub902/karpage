updateCarIndexes = (ele) ->
  $parent = $(this.el)
  ids = $parent.find('.car-card').map ->
    $(this).data('id')
  $.post $parent.data('update-url'), ids: ids.toArray().join()

$container = $('.own-profile .my-cars.draggable')
if $container.length > 0
  $container.each ->
    Sortable.create(
      $(this).find('.car-cards')[0]
      draggable: '.car-card'
      onSort: updateCarIndexes
    )
