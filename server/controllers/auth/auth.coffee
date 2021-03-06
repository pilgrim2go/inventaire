__ = require('config').universalPath
ActionsControllers = __.require 'lib', 'actions_controllers'
{ signup, login, logout } = require './connection'
{ usernameAvailability, emailAvailability } = require './availability'

module.exports =
  get: ActionsControllers
    public:
      'username-availability': usernameAvailability
      'email-availability': emailAvailability
    authentified:
      'wikidata-oauth': require './wikidata_oauth'

  post: ActionsControllers
    public:
      'signup': signup
      'login': login
      'logout': logout
      'reset-password': require './reset_password'
    authentified:
      'email-confirmation': require './email_confirmation'
      'update-password': require './update_password'
