CONFIG = require 'config'
__ = CONFIG.universalPath
{ membershipActionsList } = __.require 'models', 'group'

module.exports = (db)->
  MembershipUpdate = require('./membership_update')(db)

  actions = {}
  membershipActionsList.forEach (action)->
    actions[action] = MembershipUpdate(action)

  return actions
