CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
promises_ = __.require 'lib', 'promises'
error_ = __.require 'lib', 'error/error'
couch_ = __.require 'lib', 'couch'
Task = __.require 'models', 'task'

db = __.require('couch', 'base')('tasks')

module.exports = tasks_ =
  create: (taskDoc)->
    promises_.try -> Task.create taskDoc
    .then db.postAndReturn
    .then _.Log('task created')

  update: (options)->
    { id, attribute, value } = options
    db.update id, (doc)-> Task.update doc, attribute, value
    .then _.Log('tasks updated')

  updateSuggestion: (options)->
    { id, suggestionUri, attribute, value } = options
    db.update id, (doc)->
      Task.updateSuggestion doc, suggestionUri, attribute, value
    .then _.Log('task suggestion updated')

  byId: db.get

  byIds: db.fetch

  byScore: (limit)->
    db.viewCustom 'byScore',
      limit: limit
      descending: true
      include_docs: true

  bySuspectUri: (suspectUri)->
    db.viewByKey 'bySuspectUri', suspectUri
    .then couch_.firstDoc

  bySuspectUris: (suspectUris)->
    db.viewByKeys 'bySuspectUri', suspectUris

  keepNewTasks: (newTasks)->
    suspectUris = _.pluck newTasks, 'suspectUri'
    tasks_.bySuspectUris suspectUris
    .then (existingTasks)->
      existingSuspectUris = _.pluck existingTasks, 'suspectUri'
      newTasks.filter isNewSuspectUriTask(existingSuspectUris)

isNewSuspectUriTask = (existingSuspectUris)-> (task)->
  task.suspectUri not in existingSuspectUris
