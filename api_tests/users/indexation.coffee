CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
should = require 'should'
promises_ = __.require 'lib', 'promises'
{ getUser, customUser, undesiredErr, undesiredRes } = __.require 'apiTests', 'utils/utils'
{ host:elasticHost } = CONFIG.elasticsearch
dbName = CONFIG.db.name 'users'

describe 'users:indexation', ->
  it 'should index new user', (done)->
    getUser()
    .delay 100
    .then (user)->
      { _id } = user
      promises_.get "#{elasticHost}/#{dbName}/user/#{_id}"
      .then (res)->
        res._id.should.equal _id
        { _source } = res
        _source.should.be.an.Object()
        _source.username.should.be.a.String()
        _source.picture.should.be.a.String()
        # Omitted private attributes
        should(_source.settings).not.be.ok()
        should(_source.snapshot).not.be.ok()
        should(_source.readToken).not.be.ok()
        done()

    .catch undesiredErr(done)

    return

  it 'should remove a deleted user', (done)->
    { customUserReq, getCustomUser } = customUser()
    getCustomUser()
    .then (user)->
      { _id } = user
      customUserReq 'delete', '/api/user'
      .delay 1000
      .then -> promises_.get "#{elasticHost}/#{dbName}/user/#{_id}"
      .then undesiredRes(done)
      .catch (err)->
        err.body.found.should.be.false()
        done()

    .catch undesiredErr(done)

    return