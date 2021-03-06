window.initializeMentions = ($root) ->
  userSearchDelay = null
  getUsers = (query, callback) ->
    clearTimeout(userSearchDelay) if userSearchDelay
    return if query == ''
    userSearchDelay = setTimeout ->
      $.getJSON "/users", search: query, deep_search: false, friends_first: true, format: 'json', (data) ->
        callback(data.users)
    , 100

  hashtagSearchDelay = null
  getHashtags = (query, callback) ->
    clearTimeout(hashtagSearchDelay) if hashtagSearchDelay
    return if query == ''
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
        limit: 10
        callbacks:
          remoteFilter: (query, callback) ->
            mentions = this.$inputor.val().match(/\B@([\w-]+)/g)
            return if mentions && mentions.length > 5
            getUsers(query, callback)
          tplEval: (_tpl, map) ->
            name = if map.name then "#{map.name} " else ""
            img = if map.avatar_url then "<img class='avatar' src='#{map.avatar_url}' width='32' height='32'>" else "<div class='spacer'></div>"
            "<li data-login='#{map.login}'>#{img}#{name}<em>#{map.login}</em></li>"
          beforeInsert: (value, $li) ->
            "@#{$li.data('login')}"
          sorter: (query, items, searchKey) -> items
        searchKey: 'login'
      .atwho
        at: '#'
        limit: 10
        callbacks:
          remoteFilter: (query, callback) ->
            hashtags = this.$inputor.val().match(/\B#([\w-]+)/g)
            return if hashtags && hashtags.length > 5
            getHashtags(query, callback)

$ ->
  initializeMentions $('body')
  $(document).on 'show.bs.modal', (e) ->
    initializeMentions($(e.target))
