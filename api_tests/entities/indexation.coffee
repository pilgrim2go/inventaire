CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
should = require 'should'
promises_ = __.require 'lib', 'promises'
{ nonAuthReq, authReq, adminReq, undesiredErr, undesiredRes } = __.require 'apiTests', 'utils/utils'
{ host:elasticHost } = CONFIG.elasticsearch
dbName = CONFIG.db.name 'entities'

describe 'entities:indexation', ->
  it 'should index entity on creation', (done)->
    createWorkEntity()
    .delay 100
    .then (res)->
      { _id } = res
      promises_.get "#{elasticHost}/#{dbName}/work/#{_id}"
      .then (res)->
        res._id.should.equal _id
        res._source.should.be.an.Object()
        res._source.labels.should.be.an.Object()
        res._source.claims.should.be.an.Object()
        done()

    .catch undesiredErr(done)

    return

  it 'should re-index entity on update', (done)->
    createWorkEntity()
    .then (res)->
      { _id } = res
      authReq 'put', '/api/entities?action=update-label',
        id: _id
        lang: 'de'
        value: 'moin'
      .delay 100
      .then (res)->
        promises_.get "#{elasticHost}/#{dbName}/work/#{_id}"
        .then (res)->
          res._source.labels.de.should.equal 'moin'
          done()

    .catch undesiredErr(done)

    return

  it 'should remove from index when redirected', (done)->
    promises_.all [
      createWorkEntity()
      createWorkEntity()
    ]
    .spread (workA, workB)->
      idA = workA._id
      idB = workB._id
      elasticUrl = "#{elasticHost}/#{dbName}/work/#{idA}"
      promises_.get elasticUrl
      .delay 100
      .then (checkRes)->
        checkRes.found.should.be.true()
        adminReq 'put', '/api/entities?action=merge',
          from: "inv:#{idA}"
          to: "inv:#{idB}"
        .delay 100
        .then ->
          promises_.get elasticUrl
          .then undesiredRes(done)
          .catch (err)->
            err.body.found.should.be.false()
            done()

    .catch undesiredErr(done)

    return

  it 'should remove from index when deleted', (done)->
    promises_.all [
      createAuthorEntity()
      createWorkEntity()
    ]
    .spread (author, work)->
      workId = work._id
      authReq 'put', '/api/entities?action=update-claim',
        id: workId
        property: 'wdt:P50'
        'new-value': "inv:#{author._id}"
      .then ->
        adminReq 'put', '/api/entities?action=merge',
          from: "inv:#{workId}"
          to: "wd:Q488337"
      .delay 100
      .then (res)->
        promises_.get "#{elasticHost}/#{dbName}/human/#{author._id}"
        .then undesiredRes(done)
        .catch (err)->
          err.body.found.should.be.false()
          done()

    .catch undesiredErr(done)

    return

createAuthorEntity = ->
  authReq 'post', '/api/entities?action=create',
    labels: { fr: 'bla' }
    claims: { 'wdt:P31': [ 'wd:Q5' ] }

createWorkEntity = ->
  authReq 'post', '/api/entities?action=create',
    labels: { fr: 'bla' }
    claims: { 'wdt:P31': [ 'wd:Q571' ] }
