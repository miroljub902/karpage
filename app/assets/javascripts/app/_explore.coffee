$ ->
  $form = $('form.car-search')
  $location = $form.find('input#location')

  return if $form.length == 0 || $location.length == 0

  $lat = $form.find('input#lat')
  $lng = $form.find('input#lng')

  $location.on 'keydown', (e) ->
    e.preventDefault() if e.keyCode == 13 && $('.pac-container:visible').length

  options =
    types: ['geocode']
  autocomplete = new google.maps.places.Autocomplete($location.get(0), options)
  autocomplete.addListener 'place_changed', ->
    place = autocomplete.getPlace()
    if place
      $lat.val place.geometry.location.lat()
      $lng.val place.geometry.location.lng()

  $form.find('.radius-select input').on 'change', ->
    $form.submit()
