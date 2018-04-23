class window.VideoPlayer
  constructor: ($ele) ->
    @$ele = $ele.data('video-player-initialized', true)
    @$video = $ele.find('video')
      .on 'click', (e) => @handlePlayPause(e)
      .on 'ended', (e) => @handleVideoEnded(e)
    @video = @$video.get(0)

  handlePlayPause: ->
    if @video.paused then @play() else @pause()

  handleVideoEnded: ->
    @pause()

  play: ->
    @$ele.removeClass('video-player--paused').addClass('video-player--playing')
    @video.play()

  pause: ->
    @$ele.removeClass('video-player--playing').addClass('video-player--paused')
    @video.pause()

$ ->
  $('.video-player').each ->
    new VideoPlayer($(this))
