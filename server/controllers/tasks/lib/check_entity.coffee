CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
error_ = __.require 'lib', 'error/error'
getEntityByUri = __.require 'controllers', 'entities/lib/get_entity_by_uri'
tasks_ = require './tasks'
buildTaskDocs = require './build_task_docs'
keepNewTasks = require './keep_new_tasks'

module.exports = (uri)->
  getEntityByUri uri
  .then (entity)->
    unless entity? then throw error_.notFound { uri }
    if entity.uri.split(':')[0] is 'wd'
      throw error_.new 'entity is already a redirection', 400, { uri }
    return buildTaskDocs entity
  .then keepNewTasks
  .map tasks_.create
