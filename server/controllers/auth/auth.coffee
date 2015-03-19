CONFIG = require 'config'
__ = CONFIG.root
_ = __.require 'builders', 'utils'
user_ = __.require 'lib', 'user/user'
User = __.require 'models', 'user'
promises_ = __.require 'lib', 'promises'
passport_ = __.require 'lib', 'passport/passport'

exports.signup = (req, res, next)->
  _.log req.body, 'req.body'
  {strategy} = req.body
  switch strategy
    when 'local' then passport_.authenticate.localSignup(req, res, next)
    else _.errorHandler(res, "unknown signup strategy: #{strategy}", 400)

exports.login = (req, res, next)->
  {strategy} = req.body
  switch strategy
    when 'local' then passport_.authenticate.localLogin(req, res, next)
    when 'browserid' then passport_.authenticate.browserid(req, res, next)
    else _.errorHandler(res, "unknown login strategy: #{strategy}", 400)

exports.logout = (req, res, next) ->
  res.clearCookie 'loggedIn'
  req.logout()
  res.redirect '/'

_.extend exports, require('./availability')

exports.token = require './token'