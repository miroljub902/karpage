window.initializeMentions = ($root) ->
  userSearchDelay = null
  getUsers = (query, callback) ->
    clearTimeout(userSearchDelay) if userSearchDelay
    return if query == ''
    $input = this.$inputor
    userSearchDelay = setTimeout ->
      $.getJSON "//#{Config.apiBase}/api/users", search: query, friends_first: true, format: 'json', (data) ->
        callback(data.users)
    , 100

  hashtagSearchDelay = null
  getHashtags = (query, callback) ->
    clearTimeout(hashtagSearchDelay) if hashtagSearchDelay
    return if query == ''
    $input = this.$inputor
    hashtagSearchDelay = setTimeout ->
      $.getJSON "//#{Config.apiBase}/api/hashtags", search: query, format: 'json', (data) ->
        hashtags = data.hashtags.map (hashtag) -> hashtag.tag
        hashtags.push query
        callback hashtags
    , 100

  $root.find('.js-mentions').each ->
    $this = $(this)
    return if $this.data('atwho')
    $this
      .atwho
        at: '@'
        callbacks:
          remoteFilter: getUsers
          tplEval: (_tpl, map) ->
            name = if map.name then "#{map.name} " else ""
            img = if map.avatar_url then "<img class='avatar' src='#{map.avatar_url}' width='32' height='32'>" else "<div class='spacer'></div>"
            "<li data-login='#{map.login}'>#{img}#{name}<em>#{map.login}</em></li>"
          beforeInsert: (value, $li) ->
            "@#{$li.data('login')}"
        searchKey: 'login'
      .atwho
        at: '#'
        callbacks:
          remoteFilter: getHashtags

$ ->
  initializeMentions $('body')
  $(document).on 'show.bs.modal', (e) ->
    initializeMentions($(e.target))
