CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
{ pass, entityUri } = require './common'

attributes = require '../attributes/task'
taskAttributes = Object.keys attributes.task
suggestionAttributes = Object.keys attributes.suggestion

module.exports =
  pass: pass
  # in attributes/task.coffee, attributes keys should match
  # db keys to verify if attribute is updatable
  attribute: (attribute)-> attribute in taskAttributes
  type: (taskType)-> taskType in attributes.task.type
  state: (taskState)-> taskState in attributes.task.state

  suggestion:
    attribute: (attribute)-> attribute in suggestionAttributes
    state: (state)-> state in attributes.suggestion.state

  suspectUri: entityUri
  lexicalScore: _.isNumber
  hasEncyclopediaOccurence: _.isBoolean
