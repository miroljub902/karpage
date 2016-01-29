$ ->
  $('.js-back-to-top').click (e) ->
    e.preventDefault()
    $('html,body').animate { scrollTop: 0 }, 1000

  $nav = $('#navmain')
  return unless $nav.data('affix')
  $header = $nav.parent()
  height = $nav.outerHeight()

  $nav.affix(offset: { top: 10 })
    .on 'affixed-top.bs.affix', ->
      $nav.css('margin-top', '0')
      $header.css('padding-top', '0')
    .on 'affixed.bs.affix', ->
      $nav.css('margin-top', "-#{height}px")
      $header.css('padding-top', "#{height}px")
