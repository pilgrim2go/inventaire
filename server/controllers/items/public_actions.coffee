__ = require('config').root
_ = __.require 'builders', 'utils'
items_ = __.require 'lib', 'items'
user_ = __.require 'lib', 'user/user'
couch_ = __.require 'lib', 'couch'
error_ = __.require 'lib', 'error/error'
Item = __.require 'models', 'item'
Promise = require 'bluebird'
{ Username, UserId, EntityUri } = __.require 'models', 'tests/common-tests'

module.exports =
  lastPublicItems: (req, res, next) ->
    items_.publicByDate(15)
    .then bundleOwnersData.bind(null, res)
    .catch error_.Handler(res)

  userPublicItems: (req, res, next)->
    _.info req.query, 'userPublicItems'
    {user} = req.query
    unless UserId.test(user)
      return error_.bundle res, 'bad userId', 400

    items_.byListing(user, 'public')
    .then res.json.bind(res)
    .catch error_.Handler(res)

  publicByEntity: (req, res, next) ->
    _.info req.query, 'publicByEntity'
    {uri} = req.query
    unless EntityUri.test(uri)
      return error_.bundle res, 'bad entity uri', 400

    items_.publicByEntity(uri)
    .then bundleOwnersData.bind(null, res)
    .catch error_.Handler(res)

  publicByUsernameAndEntity: (req, res, next)->
    _.info req.query, 'publicByUserAndEntity'
    {username, uri} = req.query

    unless EntityUri.test(uri)
      return error_.bundle res, 'bad entity uri', 400
    unless Username.test(username)
      return error_.bundle res, 'bad username', 400

    user_.getSafeUserFromUsername(username)
    .then (user)->
      {_id} = user
      unless _id?
        return error_.new 'user not found', 404

      owner = _id
      items_.publicByOwnerAndEntity(owner, uri)
      .then (items)-> res.json {items: items, user: user}

    .catch error_.Handler(res)

bundleOwnersData = (res, items)->
  unless items?.length > 0
    return error_.bundle res, 'no item found', 404

  users = getItemsOwners(items)
  user_.getUsersPublicData(users)
  .then (users)-> res.json {items: items, users: users}

getItemsOwners = (items)->
  users = items.map (item)-> item.owner
  return _.uniq(users)
