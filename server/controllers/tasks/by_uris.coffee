__ = require('config').universalPath
_ = __.require 'builders', 'utils'
responses_ = __.require 'lib', 'responses'
error_ = __.require 'lib', 'error/error'
tasks_ = require './lib/tasks'
sanitize = __.require 'lib', 'sanitize/sanitize'

sanitization =
  uris: {}

byUris = (fnName)-> (req, res)->
  sanitize req, res, sanitization
  .then (params)->
    { uris } = params
    tasks_[fnName](uris)
    .then (tasks)->
      index = uris.reduce buildIndex, {}
      tasks.reduce regroup[fnName], index
  .then responses_.Wrap(res, 'tasks')
  .catch error_.Handler(req, res)

buildIndex = (index, uri)->
  index[uri] = []
  return index

regroupBy = (uriName)-> (tasks, task)->
  tasks[task[uriName]].push task
  return tasks

regroup =
  bySuspectUris: regroupBy 'suspectUri'
  bySuggestionUris: regroupBy 'suggestionUri'

module.exports =
  bySuspectUris: byUris 'bySuspectUris'
  bySuggestionUris: byUris 'bySuggestionUris'