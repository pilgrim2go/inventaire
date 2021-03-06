CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require('builders', 'utils')
user_ = __.require 'controllers', 'user/lib/user'
error_ = __.require 'lib', 'error/error'

module.exports = (res, reqUserId, items)->
  unless items?.length > 0
    throw error_.new 'no item found', 404
  usersIds = getItemsOwners items
  user_.getUsersByIds usersIds, reqUserId
  .then (users)-> res.json { items, users }

getItemsOwners = (items)->
  users = items.map (item)-> item.owner
  return _.uniq users
