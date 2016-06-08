mosca = require 'mosca'

settings = [
  port : 1883
]

# Accepts the connection if the username and password are valid
authenticate = (client, username, password, callback) ->
  authorized_bot = username == 'bot' and password.toString() == 'meinkampf666'
  authorized_admin = username == 'admin' and password.toString() == 'literallyhitler666'

  if authorized_bot
    client.user = username
    callback null, authorized_bot
    return
  if authorized_admin
    client.user = username
    callback null, authorized_admin
    return
  else
    return

authorizePublish = (client, topic, payload, callback) ->
  if client.user == 'bot'
    callback null, 'data/bot'
    return
  if client.user == 'admin'
    callback null, 'shell/bot'
    return


authorizeSubscribe = (client, topic, callback) ->
  if client.user == 'bot'
    callback null, 'shell/bot'
    return
  if client.user == 'admin'
    callback null, 'data/bot'
    return


server = new (mosca.Server)(settings)
setup = ->
  server.authenticate = authenticate
  server.authorizePublish = authorizePublish
  server.authorizeSubscribe = authorizeSubscribe
  return

#start server
server.on 'ready', setup
