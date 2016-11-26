_ = require 'lodash'
Promise = require 'bluebird'
findKeys = require './find_keys'
{ red } = require 'chalk'
{ getSources, writeDistVersion } = require './json_files_handlers'

module.exports = (lang)->
  Promise.props getSources(lang)
  .then (params)->
    [ dist ] = findKeys params
    writeDistVersion lang, dist
  .catch (err)->
    console.error red("#{lang} err"), err.stack
    throw err
