__ = require('config').universalPath
_ = __.require 'builders', 'utils'
user_ = __.require 'controllers', 'user/lib/user'
error_ = __.require 'lib', 'error/error'
{ buildSearcher } = __.require 'lib', 'elasticsearch'

module.exports = (req, res) ->
  { query } = req
  search = query.search?.trim()
  reqUserId = req.user?._id

  unless _.isNonEmptyString search
    return error_.bundleInvalid req, res, 'search', search

  searchByUsername search
  .then _.Wrap(res, 'users')
  .catch error_.Handler(req, res)

searchByUsername = buildSearcher
  dbBaseName: 'users'
  queryBodyBuilder: (search)->
    should = [
      { match: { username: search } }
      { match_phrase_prefix: { username: search } }
      { fuzzy: { username: search } }
    ]

    return { query: { bool: { should } } }
