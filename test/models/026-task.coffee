CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
should = require 'should'
Task = __.require 'models', 'task'

validDoc = ->
  type: 'deduplicate'
  suspectUri: 'inv:035a93cc360f4e285e955bc1230415c4'
  suggestions: [
    {
      uri: 'wd:Q42'
      lexicalScore: 4.2
      hasEncyclopediaOccurence: false
    },
    {
      uri: 'wd:Q535'
      lexicalScore: 3
      hasEncyclopediaOccurence: true
    }
  ]

describe 'task model', ->
  describe 'create', ->
    it 'should return an object with type', (done)->
      taskDoc = Task.create validDoc()
      taskDoc.should.be.an.Object()
      taskDoc.type.should.equal 'deduplicate'
      done()

    it 'should return suspectUri and an array of suggestions', (done)->
      taskDoc = Task.create validDoc()
      taskDoc.suspectUri.should.equal validDoc().suspectUri
      taskDoc.suggestions.should.be.an.Array()
      taskDoc.suggestions[0].uri.should.be.a.String()
      taskDoc.suggestions[0].lexicalScore.should.be.a.Number()
      taskDoc.suggestions[0].hasEncyclopediaOccurence.should.be.a.Boolean()
      _.expired(taskDoc.created, 100).should.equal false
      done()

    it 'should throw if no suspect', (done)->
      invalidDoc =
        type: 'deduplicate'
        suggestions: { uri: 'wd:Q42' }
      createTaskDoc = -> Task.create invalidDoc
      createTaskDoc.should.throw()
      done()

    it 'should throw if empty suspect', (done)->
      invalidDoc =
        type: 'deduplicate'
        suspectId: ''
        suggestions: { uri: 'wd:Q42' }
      createTaskDoc = ->Task.create invalidDoc
      try createTaskDoc()
      catch err then err.message.should.startWith 'invalid suspect'
      createTaskDoc.should.throw()
      done()

    it 'should throw if suggestion has no uri', (done)->
      invalidDoc = validDoc()
      delete invalidDoc.suggestions[0].uri
      createTaskDoc = -> Task.create invalidDoc
      try createTaskDoc()
      catch err then err.message.should.startWith 'invalid uri'
      createTaskDoc.should.throw()
      done()

    it 'should throw if suggestion has no lexicalScore', (done)->
      invalidDoc = validDoc()
      delete invalidDoc.suggestions[0].lexicalScore
      createTaskDoc = -> Task.create invalidDoc
      try createTaskDoc()
      catch err then err.message.should.startWith 'invalid lexicalScore'
      createTaskDoc.should.throw()
      done()

    it 'should throw if suggestion has no hasEncyclopediaOccurence', (done)->
      invalidDoc = validDoc()
      delete invalidDoc.suggestions[0].hasEncyclopediaOccurence
      createTaskDoc = -> Task.create invalidDoc
      try createTaskDoc()
      catch err then err.message.should.startWith 'invalid hasEncyclopediaOccurence'
      createTaskDoc.should.throw()
      done()

    it 'should sort suggestions by score', (done)->
      createdDoc = Task.create validDoc()
      createdDoc.suggestions[0].uri.should.equal 'wd:Q535'
      createdDoc.suggestions[1].uri.should.equal 'wd:Q42'
      done()

  describe 'update', ->
    it 'should update a valid task with an merged state', (done)->
      taskDoc = Task.update validDoc(), 'state', 'merged'
      taskDoc.state.should.equal 'merged'
      done()

    it 'should throw if invalid attribute to update', (done)->
      updateTaskDoc = -> Task.update validDoc(), 'blob', 'merged'
      try updateTaskDoc()
      catch err then err.message.should.startWith 'invalid attribute'
      updateTaskDoc.should.throw()
      done()

    it 'should throw if invalid value', (done)->
      updateTaskDoc = -> Task.update validDoc(), 'state', 'dismissed'
      try updateTaskDoc()
      catch err then err.message.should.startWith 'invalid state'
      updateTaskDoc.should.throw()
      done()

  describe 'update suggestion', ->
    it 'should update a valid task suggestion with a dismissed state', (done)->
      taskDoc = Task.updateSuggestion validDoc(), 'wd:Q42', 'state', 'dismissed'
      suggestion = _.find taskDoc.suggestions, { uri: 'wd:Q42' }
      suggestion.state.should.equal 'dismissed'
      done()

    it 'should throw if invalid suggestion attribute to update', (done)->
      updateTaskDoc = ->
        Task.updateSuggestion validDoc(), 'wd:Q42', 'blob', 'dismissed'
      try updateTaskDoc()
      catch err then err.message.should.startWith 'invalid suggestion.attribute'
      updateTaskDoc.should.throw()
      done()

    it 'should throw if invalid value', (done)->
      updateTaskDoc = ->
        Task.updateSuggestion validDoc(), 'wd:Q42', 'state', 'invalidValue'
      try updateTaskDoc()
      catch err then err.message.should.startWith 'invalid suggestion.state'
      updateTaskDoc.should.throw()
      done()

    it 'should put the dismissed suggestions at the end', (done)->
      updatedDoc = Task.updateSuggestion validDoc(), 'wd:Q535', 'state', 'dismissed'
      updatedDoc.suggestions[0].uri.should.equal 'wd:Q42'
      updatedDoc.suggestions[1].uri.should.equal 'wd:Q535'
      updatedDoc.suggestions[1].state.should.equal 'dismissed'
      done()
