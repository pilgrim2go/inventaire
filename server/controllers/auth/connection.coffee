CONFIG = require 'config'
{ cookieMaxAge } = CONFIG
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
sanitize = __.require 'lib', 'sanitize/sanitize'
error_ = __.require 'lib', 'error/error'
passport_ = __.require 'lib', 'passport/passport'
setLoggedInCookie = require './lib/set_logged_in_cookie'
{ ownerSafeData } = __.require 'controllers', 'user/lib/authorized_user_data_pickers'

sanitization =
  username: {}
  email: {}
  password: {}

# TODO: rate limit to 10 signup per IP per 10 minutes
exports.signup = (req, res)->
  sanitize req, res, sanitization
  .then (params)->
    { username, email, password } = params
    next = LoggedIn req, res
    # TODO: rewrite passport response to use responses_.send
    passport_.authenticate.localSignup req, res, next
  .catch error_.Handler(req, res)

exports.login = (req, res)->
  next = LoggedIn req, res
  passport_.authenticate.localLogin req, res, next

LoggedIn = (req, res)->
  loggedIn = (result)->
    if result instanceof Error then error_.handler req, res, result
    else
      setLoggedInCookie res
      data = { ok: true }
      # add a 'include-user-data' option to access user data directly from the login request
      # Use case: inventaire-wiki (jingo) login
      # https://github.com/inventaire/jingo/blob/635f5417b7ca5a99bad60b32c1758ccecd0e3afa/lib/auth/local-strategy.js#L26
      if req.query['include-user-data'] then data.user = ownerSafeData req.user
      res.json data

exports.logoutRedirect = logoutRedirect = (redirect, req, res, next)->
  res.clearCookie 'loggedIn'
  req.logout()
  res.redirect redirect

exports.logout = logoutRedirect.bind null, '/'
