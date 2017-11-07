$ ->
  $form = $('.js-hashtag-search')
  $tag = $form.find('input.hashtag')

  $tag.typeahead
    source: (query, callback) ->
      $.getJSON '/hashtags', search: query, (data) ->
        items = for item in data.hashtags
          { name: item.tag, count: item.unique_count }
        callback items
    afterSelect: (item) ->
      window.location = "/hashtags/#{item.name}/"
    displayText: (item) ->
      "#{item.name} (#{item.count} #{if item.count == 1 then 'post' else 'posts'})"

  $form.submit (e) ->
    e.preventDefault()
    window.location = "/hashtags/#{$tag.val()}/"
