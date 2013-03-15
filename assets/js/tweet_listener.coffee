socket = io.connect('/')

$ ->

  spin_opts =
    lines: 17 # The number of lines to draw
    length: 12 # The length of each line
    width: 20 # The line thickness
    radius: 10 # The radius of the inner circle
    corners: 0.5 # Corner roundness (0..1)
    rotate: 0 # The rotation offset
    color: "#49a8d4" # #rgb or #rrggbb
    speed: 1 # Rounds per second
    trail: 45 # Afterglow percentage
    shadow: false # Whether to render a shadow
    hwaccel: true # Whether to use hardware acceleration
    className: "spinner" # The CSS class to assign to the spinner
    zIndex: 2e9 # The z-index (defaults to 2000000000)
    top: "auto" # Top position relative to parent in px
    left: "auto" # Left position relative to parent in px

  target = document.getElementById("spinner")
  spinner = new Spinner(spin_opts).spin(target)

  $tweet_list    = $("#tweet_list")
  max_visible_tweets = 30
  visible_tweets = 0

  socket.on 'new_tweet', (tweet) ->
    build_tweet tweet

  build_tweet = (tweet) ->
    if visible_tweets >= max_visible_tweets
      $tweet_list.find("li:last").addClass('removing').remove()
    template = "<li class='hidden'><h5>#{tweet.user}</h5><p>#{tweet.content}</p></li>"
    dom_tweet = $(template).prependTo($tweet_list)
    if tweet.images.length > 0
      $("#spinner").remove() if $("#spinner").length
      for image in tweet.images
        dom_image = $("<img class='hidden' src='#{image}' />").appendTo(dom_tweet)
        dom_tweet.imagesLoaded ->
          dom_tweet.animate({'opacity', 0}, 10).removeClass 'hidden'
          dom_image.animate({'opacity', 0}, 0).removeClass 'hidden'
    visible_tweets = visible_tweets + 1