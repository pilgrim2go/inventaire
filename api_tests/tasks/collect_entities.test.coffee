CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
should = require 'should'
{ undesiredErr } = __.require 'apiTests', 'utils/utils'
{ createHuman } = require '../fixtures/entities'
{ collectEntities } = require '../fixtures/tasks'
{ getByScore } = require '../utils/tasks'

describe 'tasks:collect-entities', ->
  it 'should create new tasks', (done)->
    @timeout 30000

    collectEntities()
    .then (res)->
      suspectId = res.human._id
      getByScore { limit: 1000 }
      .then (res)->
        { tasks } = res
        tasks.length.should.aboveOrEqual 1
        tasksSuspectUris = _.pluck tasks, 'suspectUri'
        tasksSuspectUris.should.containEql "inv:#{suspectId}"
        done()
    .catch undesiredErr(done)

    return

  it 'should not re-create existing tasks', (done)->
    @timeout 30000

    collectEntities { refresh: true }
    .then -> getByScore { limit: 1000 }
    .then (res)->
      { tasks } = res
      uniqSuspectUris = _.uniq _.pluck(tasks, 'suspectUri')
      tasks.length.should.equal uniqSuspectUris.length
      done()
    .catch undesiredErr(done)

    return
