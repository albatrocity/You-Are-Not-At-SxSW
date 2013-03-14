http    = require('http')
twitter = require("ntwitter")
express = require("express")
stylus  = require 'stylus'
nib     = require 'nib'
path    = require 'path'
io      = require 'socket.io'
twexter = require('twitter-text')
assets  = require 'connect-assets'
port    = 3000

app     = express()
server  = http.createServer(app)
io      = io.listen server

app.set('title', 'You Are Not At SxSW');
# app.use assets()
app.use express.logger 'dev'
app.use express.static path.join __dirname, 'public'
app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'jade'
app.use assets()

twit = new twitter(
  consumer_key:         process.env.CONSUMER_KEY
  consumer_secret:      process.env.CONSUMER_SECRET
  access_token_key:     process.env.ACCESS_TOKEN_KEY
  access_token_secret:  process.env.ACCESS_TOKEN_SECRET
)

twit.verifyCredentials (err, data) ->
  console.log(err)


twit.stream "statuses/filter",
  track: ["#sxsw"]
, (stream) ->
  stream.on "data", (tweet) ->
    check_for_images tweet, (images) ->
      if images
        io.sockets.emit 'new_tweet',
          prepare_tweet_data(tweet)
  stream.on "error", (error) ->
    console.log error

check_for_images = (data, callback) ->
  if data.entities.urls
    for url in data.entities.urls
      if url.expanded_url.indexOf("instagr.am") != -1
        images = true
  if data.entities.media
    images = true
  callback(images)

prepare_tweet_data = (data) ->
  client_data =
      images  : []
      content : twexter.autoLink(twexter.htmlEscape(data.text))
      img     : data.user.profile_image_url.replace('_normal', '')
      user    : twexter.autoLink("@#{data.user.screen_name}")
      uid     : data.user.id
      time    : data.created_at

  if data.entities.urls
    for url in data.entities.urls
      if url.expanded_url.indexOf("instagr.am") != -1
        client_data.images.push "#{url.expanded_url}/media?size=l"
  if data.entities.media
    for media in data.entities.media
      client_data.images.push media.media_url

  return client_data if client_data.images.length > 0

app.get '/', (req, res, next) ->
  res.render 'index'

server.listen port