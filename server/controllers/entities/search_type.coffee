# A search endpoint dedicated to searching entities by types
# to fit the needs of autocomplete searches
# Relies on a local ElasticSearch instance loaded with Inventaire and Wikidata entities
# See https://github.com/inventaire/wikidata-subset-search-engine
# and server/controllers/entities/lib/update_search_engine

CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
error_ = __.require 'lib', 'error/error'
searchType = require './lib/search_type'

indexedTypes = [ 'works', 'humans', 'series', 'genres', 'movements', 'publishers', 'collections' ]

module.exports = (req, res)->
  { type, search, limit } = req.query

  _.info [ type, search, limit ], 'entities search per type'

  unless _.isNonEmptyString search
    return error_.bundleMissingQuery req, res, 'search'

  unless _.isNonEmptyString type
    return error_.bundleMissingQuery req, res, 'type'

  unless type in indexedTypes
    return error_.bundleInvalid req, res, 'type', type

  limit or= '20'

  unless _.isPositiveIntegerString limit
    return error_.bundleInvalid req, res, 'limit', limit

  limit = _.stringToInt limit

  searchType search, type, limit
  .map addUri
  .then res.json.bind(res)
  .catch error_.Handler(req, res)

# All search results should soon have a URI
# see https://github.com/inventaire/wikidata-subset-search-engine/blob/d778475/lib/format_entity.coffee#L16
# but in the meantime, we need to had them manually
addUri = (result)->
  # Only Wikidata entities miss their URI
  result.uri or= "wd:#{result.id}"
  return result
