__ = require('config').universalPath
_ = __.require 'builders', 'utils'
promises_ = __.require 'lib', 'promises'
error_ = __.require 'lib', 'error/error'
user_ = __.require 'lib', 'user/user'
User = __.require 'models', 'user'

module.exports = (req, res)->
  { ids } = req.query
  promises_.try parseAndValidateIds.bind(null, ids)
  .then _.partialRight(user_.getUsersPublicData, 'index')
  .then _.Wrap(res, 'users')
  .catch error_.Handler(req, res)

parseAndValidateIds = (ids)->
  unless _.isNonEmptyString ids then throw error_.new 'missing ids', 400, ids

  ids = ids.split '|'
  if ids?.length > 0 and validUsersIds(ids) then return ids
  else throw error_.new 'invalid ids', 400, ids

validUsersIds = (ids)-> _.all ids, User.tests.userId