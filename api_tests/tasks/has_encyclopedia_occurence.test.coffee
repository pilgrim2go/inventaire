CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
should = require 'should'
{ createHuman, createWork } = require '../fixtures/entities'
{ collectEntities } = require '../fixtures/tasks'
{ getByScore } = require '../utils/tasks'
{ undesiredErr } = __.require 'apiTests', 'utils/utils'

describe 'tasks:has-encyclopedia-occurence', ->
  it 'should return true when author has work sourced in their wikipedia page', (done)->
    @timeout 20000

    createHuman { labels: { en: 'Victor Hugo' } }
    .then (res)->
      authorUri = "inv:#{res._id}"
      createWork
        labels: { en: 'Ruy Blas' }
        claims: { 'wdt:P50': [ authorUri ] }
      .then -> collectEntities { refresh: true }
      .then getByScore
      .then (res)->
        { tasks } = res
        tasks.length.should.aboveOrEqual 1
        task = _.find tasks, { suspectUri: authorUri }
        task.suggestions[0].hasEncyclopediaOccurence.should.be.true()
        done()
      .catch undesiredErr(done)

    return
