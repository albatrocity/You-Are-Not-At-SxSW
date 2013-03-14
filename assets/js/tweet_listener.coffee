socket = io.connect('/')

$ ->

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
      for image in tweet.images
        dom_image = $("<img class='hidden' src='#{image}' />").appendTo(dom_tweet)
        dom_tweet.imagesLoaded ->
          dom_tweet.animate({'opacity', 0}, 10).removeClass 'hidden'
          dom_image.animate({'opacity', 0}, 0).removeClass 'hidden'
    visible_tweets = visible_tweets + 1