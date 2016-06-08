mosca = require 'mosca'

settings = [
  port : 1883
]


#note this uses a normal credentials.json and ignored the hash, but SHOULD respect the acl

# Accepts the connection if the username and password are valid

authenticate = (client, user, pass, cb) ->
  missingUser = !user or !pass #or !@users[user]
  if missingUser
    cb null, false
    return
  user = user.toString()
  client.user = user
  user = @users[user]

#this awful shit hashes for every connection attempt, cpu rape nightmare
#  hasher {
#    password: pass.toString()
#    salt: user.salt
#  }, (err, pass, salt, hash) ->
#    if err
#      cb err
#      return
#    success = user.hash == hash
#    cb null, success
#    return

#use simple pw checking

#the callback will be true, allowing access, if the pw == a string, muuuuuuuuch easier on fucking cpu, i mean jesus who the fuck committed that garbage above fuck them
  if err
    cb err
    return
  if user == 'bot'
    success = pass.toString() == 'botpassword'
    cb null, success
    return
  if user == 'admin'
    success = pass.toString() == 'adminpass'
    cb null, success
    return


server = new (mosca.Server)(settings)
setup = ->
  server.authenticate = authenticate
  return

#start server
server.on 'ready', setup
