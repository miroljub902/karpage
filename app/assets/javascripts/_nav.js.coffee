$ ->
  $nav = $('#navmain')
  $header = $nav.parent()
  height = $nav.outerHeight()

  $nav.affix(offset: { top: 10 })
    .on 'affixed-top.bs.affix', ->
      $nav.css('margin-top', '0')
      $header.css('padding-top', '0')
    .on 'affixed.bs.affix', ->
      $nav.css('margin-top', "-#{height}px")
      $header.css('padding-top', "#{height}px")
