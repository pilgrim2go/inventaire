_ = require 'lodash'
Promise = require 'bluebird'
findKeys = require './find_keys'
{ red } = require 'chalk'
{ getSources, updateAndArchive, writeDistVersion } = require './json_files_handlers'

module.exports = extendLangWithDefault = (lang)->
  Promise.props getSources(lang)
  .then (params)->

    [ dist, update, cleanArchive ] = findKeys params

    # console.log 'dist: ', dist
    # console.log 'update: ', update
    # console.log 'cleanArchive: ', cleanArchive

    updateAndArchive lang, update, cleanArchive
    writeDistVersion lang, dist

  .catch (err)->
    console.error red("#{lang} err"), err.stack
    throw err
