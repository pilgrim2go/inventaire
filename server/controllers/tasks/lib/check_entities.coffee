__ = require('config').universalPath
_ = __.require 'builders', 'utils'
{ Promise } = __.require 'lib', 'promises'

entities_ = __.require 'controllers', 'entities/lib/entities'
checkEntity = require './check_entity'
hasWorksLabelsOccurrence = __.require 'controllers', 'entities/lib/has_works_labels_occurrence'

module.exports = (entities)->
  newTasks = []

  checkNextEntity = ->
    entity = entities.pop()
    unless entity? then return newTasks

    Promise.all [
      checkEntity entity
      getAuthorWorksData entity._id
    ]
    .spread buildTaskDoc
    .then (newTaskDoc)-> if newTaskDoc? then newTasks.push newTaskDoc
    .then checkNextEntity

  return checkNextEntity()

buildTaskDoc = (suggestionEntities, authorWorksData)->
  taskDoc =
    type: 'deduplicate'
    suspectUri: "inv:#{authorWorksData.authorId}"
    suggestions: []

  Promise.all suggestionEntities.map(addSuggestions(taskDoc, authorWorksData))
  .then -> if taskDoc.suggestions.length > 0 then return taskDoc

addSuggestions = (taskDoc, authorWorksData)-> (suggestionEntity)->
  { uri, _score: lexicalScore } = suggestionEntity
  { authorId, labels, langs } = authorWorksData

  unless uri? then return

  hasWorksLabelsOccurrence uri, labels, langs
  .then (hasEncyclopediaOccurence)->
    taskDoc.suggestions.push { uri, lexicalScore, hasEncyclopediaOccurence }
    return

getAuthorWorksData = (authorId)->
  entities_.byClaim 'wdt:P50', "inv:#{authorId}", true, true
  .then (works)->
    # works = [
    #   { labels: { fr: 'Matiere et Memoire'} },
    #   { labels: { en: 'foo' } }
    # ]
    base = { authorId, labels: [], langs: [] }
    worksData = works.reduce aggregateWorksData, base
    worksData.langs = _.uniq worksData.langs
    return worksData

aggregateWorksData = (worksData, work)->
  worksData.langs.push Object.keys(work.labels)...
  worksData.labels.push _.values(work.labels)...
  return worksData
