CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
error_ = __.require 'lib', 'error/error'
validations = require './validations/task'

module.exports =
  create: (newTask)->
    _.types arguments, [ 'object' ]

    { type, suspectUri, suggestions } = newTask

    validations.pass 'type', type
    validations.pass 'suspectUri', suspectUri

    _.type suggestions, 'array'

    for suggestion in suggestions
      { uri, lexicalScore, hasEncyclopediaOccurence } = suggestion
      validations.pass 'entityUri', uri, { altName: 'uri' }
      validations.pass 'lexicalScore', lexicalScore
      validations.pass 'hasEncyclopediaOccurence', hasEncyclopediaOccurence

      suggestionAttributes = Object.keys suggestion
      if suggestionAttributes.length isnt 3
        # In particular, the suggestion should have no state at its creation
        throw error_.new 'invalid suggestion attributes', 500, { suggestionAttributes }

      suggestion.lexicalScore = _.round lexicalScore, 2

    suggestions.sort byScore

    return task =
      type: type
      suspectUri: suspectUri
      suggestions: suggestions
      created: Date.now()

  update: (task, attribute, value)->
    _.types arguments, [ 'object', 'string', 'string|number' ]

    validations.pass 'attribute', attribute
    validations.pass attribute, value

    task[attribute] = value

    task.updated = Date.now()

    return task

  updateSuggestion: (task, suggestionUri, attribute, value)->
    _.types arguments, [ 'object', 'string', 'string', 'string|number' ]

    validations.pass 'entityUri', suggestionUri

    suggestion = _.find task.suggestions, { uri: suggestionUri }
    unless suggestion? then throw new Error 'suggestion not found'

    validations.pass 'suggestion.attribute', attribute
    validations.pass "suggestion.#{attribute}", value

    suggestion[attribute] = value

    task.suggestions.sort byScore

    task.updated = Date.now()

    return task

byScore = (suggestionA, suggestionB)->
  getScore(suggestionB) - getScore(suggestionA)

getScore = (suggestion)->
  if suggestion.state is 'dismissed' then return 0
  score = suggestion.lexicalScore
  if suggestion.hasEncyclopediaOccurence then score += 1000
  return score
