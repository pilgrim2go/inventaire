__ = require('config').universalPath
_ = __.require 'builders', 'utils'
error_ = __.require 'lib', 'error/error'
tasks_ = require './lib/tasks'

module.exports = (req, res)->
  { uris } = req.query

  unless _.isNonEmptyString uris
    return error_.bundleMissingQuery req, res, 'uris'

  uris = uris.split '|'

  for uri in uris
    unless _.isEntityUri uri
      return error_.bundleInvalid req, res, 'suspectUri', uri

  tasks_.bySuspectUris uris
  .then _.Wrap(res, 'tasks')
  .catch error_.Handler(req, res)
