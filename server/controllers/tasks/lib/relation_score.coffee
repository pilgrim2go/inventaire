__ = require('config').universalPath
_ = __.require 'builders', 'utils'

tasks_ = require './tasks'
# relationScore (between 0 & 1) express the number of tasks for the same suspect

calculateRelationScore = (tasks)->
  score = 1 / tasks.length
  _.round score, 2

updateRelationScore = (task)->
  tasks_.bySuspectUri task.suspectUri
  .then (tasks)->
    tasks_.update
      ids: _.map tasks, '_id'
      attribute: 'relationScore'
      newValue: calculateRelationScore tasks

module.exports = { calculateRelationScore, updateRelationScore }
