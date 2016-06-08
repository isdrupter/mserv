###*
# mosca.Authorizer's responsibility is to give an implementation
# of mosca.Server callback of authorizations, against a JSON file.
#
# @param {Object} users The user hash, as created by this class
#  (optional)
# @api public
###

Authorizer = (users) ->
  @users = users or {}
  return

'use strict'
hasher = require('pbkdf2-password')()
minimatch = require('minimatch')
defaultGlob = '**'
module.exports = Authorizer

###*
# It returns the authenticate function to plug into mosca.Server.
#
# @api public
###

Authorizer::__defineGetter__ 'authenticate', ->
  that = this
  (client, user, pass, cb) ->
    that._authenticate client, user, pass, cb
    return

###*
# It returns the authorizePublish function to plug into mosca.Server.
#
# @api public
###

Authorizer::__defineGetter__ 'authorizePublish', ->
  that = this
  (client, topic, payload, cb) ->
    cb null, minimatch(topic, that.users[client.user].authorizePublish or defaultGlob)
    return

###*
# It returns the authorizeSubscribe function to plug into mosca.Server.
#
# @api public
###

Authorizer::__defineGetter__ 'authorizeSubscribe', ->
  that = this
  (client, topic, cb) ->
    cb null, minimatch(topic, that.users[client.user].authorizeSubscribe or defaultGlob)
    return

###*
# The real authentication function
#
# @api private
###

Authorizer::_authenticate = (client, user, pass, cb) ->
  missingUser = !user or !pass or !@users[user]
  if missingUser
    cb null, false
    return
#  user = user.toString()
  client.user = user
#  user = @users[user]
  pword = pass.toString()
  luser = user.toString()
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
  if (luser is 'bot')
    if (pword is 'x') or (pword is null)  or (pword is undefined) or (pword is 'botpass')
      cb null, true
      return
    else
      cb null, false
      return
    return
  if (luser is 'admin')
    if  (pword is 'adminpass')
      cb null, true
      return
    else
      cb null, false
      return
    return
  else
    cb null, false
    return

###*
# An utility function to add an user.
#
# @api public
# @param {String} user The username
# @param {String} pass The password
# @param {String} authorizePublish The authorizePublish pattern
#   (optional)
# @param {String} authorizeSubscribe The authorizeSubscribe pattern
#   (optional)
# @param {Function} cb The callback that will be called after the
#   insertion.
###

Authorizer::addUser = (user, pass, authorizePublish, authorizeSubscribe, cb) ->
  that = this
  if typeof authorizePublish == 'function'
    cb = authorizePublish
    authorizePublish = null
    authorizeSubscribe = null
  else if typeof authorizeSubscribe == 'function'
    cb = authorizeSubscribe
    authorizeSubscribe = null
  if !authorizePublish
    authorizePublish = defaultGlob
  if !authorizeSubscribe
    authorizeSubscribe = defaultGlob
  hasher { password: pass.toString() }, (err, pass, salt, hash) ->
    if !err
      that.users[user] =
        salt: salt
        hash: hash
        authorizePublish: authorizePublish
        authorizeSubscribe: authorizeSubscribe
    cb err
    return
  this

###*
# An utility function to delete a user.
#
# @api public
# @param {String} user The username
# @param {String} pass The password
# @param {Function} cb The callback that will be called after the
#   deletion.
###

Authorizer::rmUser = (user, cb) ->
  delete @users[user]
  cb()
  this
