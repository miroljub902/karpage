$ ->
  previousYear = null
  checkYearTimeout = null
  $(document).on 'keyup', 'input#car_year', (e) ->
    $this = $(this)
    $form = $this.parents('form')
    year = $.trim($this.val())
    previousYear ||= year
    $makes = $form.find('select#car_make_id')
    $models = $form.find('select#car_model_id')
    $trims = $form.find('select#car_trim_id')
    if previousYear != year
      previousYear = year
      clearTimeout checkYearTimeout if checkYearTimeout
      checkYearTimeout = setTimeout ->
        $makes.find('option[value!=""]').remove()
        $models.find('option[value!=""]').remove()
        $trims.find('option[value!=""]').remove()

        unless /^\d\d\d\d$/.test(year)
          $makes.append .append("<option value='other'><OTHER></option>")
          return

        $.getJSON "//#{Config.apiBase}/api/makes", year: year, (data) ->
          $makes.append $.map data.makes, (make) ->
            "<option value='#{make.id}'>#{make.name}</option>"
          $makes.append("<option value='other'>&lt;OTHER&gt;</option>")
      , 200

  $(document).on 'change', 'select#car_make_id', (e) ->
    $this = $(this)
    $form = $this.parents('form')
    year = $.trim($form.find('input#car_year').val())
    $models = $form.find('select#car_model_id')
    $models.find('option[value!=""]').remove()
    $trims = $form.find('select#car_trim_id')
    $trims.find('option[value!=""]').remove()

    makeId = $this.val()

    if makeId == 'other'
      $form.addClass 'custom-make'
      $models.val ''
      $trims.val ''
      return
    else if makeId != ''
      $form.find('.custom-make input').val ''
      $form.removeClass 'custom-make'

    return if makeId == ''
    $.getJSON "//#{Config.apiBase}/api/makes/#{makeId}/models", year: year, (data) ->
      $models.append $.map data.models, (model) ->
        "<option value='#{model.id}'>#{model.name}</option>"

  $(document).on 'change', 'select#car_model_id', (e) ->
    $this = $(this)
    $form = $this.parents('form')

    year = $.trim($form.find('input#car_year').val())
    $makes = $form.find('select#car_make_id')
    $trims = $form.find('select#car_trim_id')
    $trims.find('option[value!=""]').remove()
    modelId = $this.val()
    return if modelId == ''
    $.getJSON "//#{Config.apiBase}/api/makes/#{$makes.val()}/models/#{modelId}/trims", year: year, (data) ->
      $trims.append $.map data.trims, (trim) ->
        "<option value='#{trim.id}'>#{trim.name}</option>"
