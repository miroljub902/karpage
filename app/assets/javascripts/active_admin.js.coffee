#= require active_admin/base
#= require chart.js/dist/Chart.bundle

$ ->
  handleTrimForm = ->
    $modelId = $('#trim_model_id')
    $makeId = $('#trim_make_id').on 'change', ->
      $modelId.find('option').remove()
      makeId = $makeId.val()
      return if makeId == ''
      $.getJSON "//#{Config.apiBase}/api/makes/#{makeId}/models", (data) ->
        $modelId.append $.map data.models, (model) ->
          "<option value='#{model.id}'>#{model.name}</option>"

  handleTrimForm()
