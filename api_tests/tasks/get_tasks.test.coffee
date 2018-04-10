CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
should = require 'should'
{ undesiredErr } = __.require 'apiTests', 'utils/utils'
{ collectEntities } = require '../fixtures/tasks'
{ getByScore, getBySuspectUris } = require '../utils/tasks'

describe 'tasks:byScore', ->
  it 'should returns 10 or less tasks to deduplicates, by default', (done)->
    collectEntities()
    .then getByScore
    .then (res)->
      res.should.be.an.Object()
      { tasks } = res
      tasks.length.should.be.belowOrEqual 10
      tasks.length.should.be.aboveOrEqual 1
      done()
    .catch undesiredErr(done)

    return

  it 'should returns a limited array of tasks to deduplicate', (done)->
    collectEntities()
    .then -> getByScore { limit: 1 }
    .then (res)->
      res.tasks.length.should.equal 1
      done()
    .catch undesiredErr(done)

    return

describe 'tasks:bySuspectUris', ->
  it 'should return the task associated with this suspectUri', (done)->
    collectEntities()
    .then -> getByScore { limit: 1 }
    .then (res1)->
      { suspectUri } = res1.tasks[0]
      getBySuspectUris suspectUri
      .then (res2)->
        res2.tasks[0].should.be.an.Object()
        res2.tasks[0].suspectUri.should.equal suspectUri
        done()
    .catch undesiredErr(done)

    return
