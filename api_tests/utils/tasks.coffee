CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
{ authReq, adminReq, undesiredErr } = __.require 'apiTests', 'utils/utils'
endpoint = '/api/tasks'
{ collectEntities } = require '../fixtures/tasks'
error_ = __.require 'lib', 'error/error'

module.exports = utils =
  getByScore: (params = {})->
    { limit } = params
    url = _.buildPath endpoint, { action: 'by-score', limit }
    authReq 'get', url
