CONFIG = require('config')
__ = CONFIG.root
_ = __.require 'builders', 'utils'

should = require 'should'
expect = require("chai").expect

Item = __.require 'models', 'item'

someUserId = '1234567890a1234567890b1234567890'
create = (item)-> Item.create.call null, someUserId, item

validItem =
  _id: 'new'
  title: 'Odysse'
  entity: 'wd:Q35160'
  listing: 'public'
  transaction: 'giving'

extendItem = (data)->
  _.extend {}, validItem, data


describe 'item model', ->
  describe 'create', ->
    it "should return an object", (done)->
      item = create validItem
      item.should.be.an.Object
      done()

    describe 'id', ->
      it "should return an object without id", (done)->
        item = create validItem
        expect(item._id).to.be.undefined
        done()

    describe 'title', ->
      it "should return an object with a title", (done)->
        item = create validItem
        item.title.should.equal validItem.title
        done()

      it "should throw on missing title", (done)->
        (-> create extendItem({title: null})).should.throw()
        done()

    describe 'entity', ->
      it "should return an object with a entity", (done)->
        item = create validItem
        item.entity.should.equal validItem.entity
        done()

      it "should throw on missing entity", (done)->
        (-> create extendItem({entity: null})).should.throw()
        done()

    describe 'listing', ->
      it "should return an object with a listing", (done)->
        item = create validItem
        item.listing.should.equal validItem.listing
        done()

      it "should use a default listing value", (done)->
        item = create extendItem({listing: null})
        item.listing.should.equal 'private'
        done()

      it "should override a bad listing with default value", (done)->
        item = create extendItem({listing: 'evillist'})
        item.listing.should.equal 'private'
        done()

    describe 'transaction', ->
      it "should return an object with a transaction", (done)->
        item = create validItem
        item.transaction.should.equal validItem.transaction
        done()

      it "should override a bad transaction with default value", (done)->
        item = create extendItem({transaction: null})
        item.transaction.should.equal 'inventorying'
        done()

      it "should override a bad transaction with default value", (done)->
        item = create extendItem({transaction: 'eviltransac'})
        item.transaction.should.equal 'inventorying'
        done()

    describe 'owner', ->
      it "should return an object with an owner", (done)->
        item = create validItem
        item.owner.should.equal someUserId
        done()

    describe 'created', ->
      it "should return an object with a created time", (done)->
        item = create validItem
        _.expired(item.created, 100).should.equal false
        done()

