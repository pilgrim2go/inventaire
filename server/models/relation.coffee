CONFIG = require 'config'
__ = CONFIG.root
_ = __.require 'builders', 'utils'
couch_ = require 'inv-couch'
assert = require 'assert'
{ userId } = require './tests/common-tests'


module.exports =
  create: (id, status)->
    assertValidId(id)
    assertValidStatus(status)
    return _.log relation =
      _id: id
      type: 'relation'
      status: status
      created: _.now()

  docId: (userId, otherId) ->
    couch_.joinOrderedIds(userId, otherId)


assertValidId = (id)->
  [ userA, userB ] = id.split ':'
  assert userA isnt userB
  _.type userA, 'string'
  assert userId(userA)
  assert userId(userB)

assertValidStatus = (status)->
  assert status in statuses

statuses = [
  'friends'
  'a-requested'
  'b-requested'
  'none'
]