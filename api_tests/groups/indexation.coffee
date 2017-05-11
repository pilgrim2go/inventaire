CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
should = require 'should'
promises_ = __.require 'lib', 'promises'
{ authReq, undesiredErr, undesiredRes } = __.require 'apiTests', 'utils/utils'
randomString = __.require 'lib', './utils/random_string'
{ host:elasticHost } = CONFIG.elasticsearch
dbName = CONFIG.db.name 'groups'

describe 'groups:indexation', ->
  it 'should index new group', (done)->
    authReq 'post', '/api/groups?action=create',
      name: 'my group' + randomString(5)
    .delay 100
    .then (group)->
      { _id } = group
      promises_.get "#{elasticHost}/#{dbName}/group/#{_id}"
      .then (res)->
        res._id.should.equal _id
        { _source } = res
        _source.should.be.an.Object()
        _source.admins.should.be.an.Object()
        _source.members.should.be.a.Object()
        done()
    .catch undesiredErr(done)

    return

  it 'should not index a non-searchable group', (done)->
    authReq 'post', '/api/groups?action=create',
      name: 'my group' + randomString(5)
      searchable: false
    .delay 100
    .then (group)->
      { _id } = group
      promises_.get "#{elasticHost}/#{dbName}/group/#{_id}"
    .then undesiredRes(done)
    .catch (err)->
      err.body.found.should.be.false()
      done()

    return

  it 'should re-index an updated group', (done)->
    authReq 'post', '/api/groups?action=create',
      name: 'my group' + randomString(5)
    .delay 10
    .then (group)->
      groupId = group._id
      updatedName = group.name + '-updated'
      authReq 'put', '/api/groups?action=update-settings',
        group: groupId
        attribute: 'name',
        value: updatedName
      .delay 100
      .then (group)->
        { _id } = group
        promises_.get "#{elasticHost}/#{dbName}/group/#{groupId}"
        .then (res)->
          res._source.name.should.equal updatedName
          done()

    return

  it 'should not index an updated non-searchable group', (done)->
    authReq 'post', '/api/groups?action=create',
      name: 'my group' + randomString(5)
      searchable: false
    .delay 10
    .then (group)->
      groupId = group._id
      updatedName = group.name + '-updated'
      authReq 'put', '/api/groups?action=update-settings',
        group: groupId
        attribute: 'name',
        value: updatedName
      .delay 100
      .then (group)->
        { _id } = group
        promises_.get "#{elasticHost}/#{dbName}/group/#{groupId}"
        .then undesiredRes(done)
        .catch (err)->
          err.body.found.should.be.false()
          done()

    return

  it 'should index a newly searchable group', (done)->
    name = 'my group' + randomString(5)
    authReq 'post', '/api/groups?action=create', { name, searchable: false }
    .delay 10
    .then (group)->
      groupId = group._id
      authReq 'put', '/api/groups?action=update-settings',
        group: groupId
        attribute: 'searchable',
        value: true
      .delay 100
      .then (group)->
        promises_.get "#{elasticHost}/#{dbName}/group/#{groupId}"
        .then (res)->
          res.found.should.be.true()
          res._source.name.should.equal name
          done()
      .catch undesiredErr(done)

    return

  it 'should remove a deleted group', (done)->
    authReq 'post', '/api/groups?action=create',
      name: 'my group' + randomString(5)
    .delay 10
    .then (group)->
      groupId = group._id
      # Leaving as the only member auto-deletes the group
      authReq 'put', '/api/groups?action=leave', { group: groupId }
      .delay 100
      .then (group)->
        promises_.get "#{elasticHost}/#{dbName}/group/#{groupId}"
        .then undesiredRes(done)
        .catch (err)->
          err.body.found.should.be.false()
          done()

    return
