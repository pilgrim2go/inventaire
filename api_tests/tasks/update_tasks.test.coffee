CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
should = require 'should'
{ authReq, adminReq } = require '../utils/utils'
{ getAnyNonMergedTask, getBySuspectUris, updateTask } = require '../utils/tasks'
{ merge: mergeEntities } = require '../utils/entities'

describe 'tasks:update', ->
  it 'should update a task', (done)->
    getAnyNonMergedTask()
    .then (task)->
      suggestion = task.suggestions[0]
      suggestion.state.should.equal 'requested'
      updateTask task._id, suggestion.uri, 'state', 'dismissed'
      .then (updatedTask)->
        updatedTask.ok.should.be.true()
        done()
    .catch done

    return

  it 'should throw if invalid task id', (done)->
    getAnyNonMergedTask()
    .then (task)->
      suggestion = task.suggestions[0]
      updateTask '', suggestion.uri, 'state', 'dismissed'
      .catch (err)->
        err.body.status_verbose.should.equal 'missing parameter in body: id'
        done()
    .catch done

    return

describe 'tasks:merge-entities', ->
  it 'should update task state from requested to merged', (done) ->
    getAnyNonMergedTask()
    .then (task)->
      mergeEntities task.suspectUri, task.suggestions[0].uri
      .delay 10
      .then -> getBySuspectUris task.suspectUri
      .then (res)->
        updatedTask = res.tasks[0]
        updatedTask.state.should.equal 'merged'
        done()
    .catch done

    return
