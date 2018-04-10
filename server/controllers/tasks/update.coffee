__ = require('config').universalPath
_ = __.require 'builders', 'utils'
error_ = __.require 'lib', 'error/error'
{ Track } = __.require 'lib', 'track'
tasks_ = __.require 'controllers', 'tasks/lib/tasks'
radio = __.require 'lib', 'radio'

promises_ = __.require 'lib', 'promises'

module.exports = (req, res, next)->
  { id, 'suggestion-uri': suggestionUri, attribute, value } = req.body
  _.log id, 'update task'

  unless _.isNonEmptyString id
    return error_.bundleMissingBody req, res, 'id'

  # The endpoint only allows to update tasks suggestions attributes,
  # the root task attributes being updated internally
  unless _.isNonEmptyString suggestionUri
    return error_.bundleMissingBody req, res, 'suggestionUri'

  tasks_.updateSuggestion { id, suggestionUri, attribute, value }
  .then res.json.bind(res)
  .tap Track(req, [ 'task', 'update' ])
  .catch error_.Handler(req, res)

updateTaskStateOnEntityMerge = (fromUri, toUri)->
  tasks_.bySuspectUri fromUri
  .then (task)->
    tasks_.update { id: task._id, attribute: 'state', value: 'merged' }

radio.on 'entity:merge', updateTaskStateOnEntityMerge
