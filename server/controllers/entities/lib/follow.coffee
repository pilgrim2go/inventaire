# Update ElasticSearch entities index, with ElasticSearch type corresponding
# to entities own types when available
CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
follow = __.require 'lib', 'follow'
dbBaseName = 'entities'
getEntityType = require './get_entity_type'
elastic = __.require('lib', 'elastic_api')(dbBaseName)

indexedTypes = [ 'human', 'serie', 'work', 'edition' ]

# Entity redirections keep the type 'entity' so no need of a specific rule
filter = (doc)->
  # Do not filter-out removed:placeholder so that changing an entity into
  # a removed placeholder triggers an ElasticSearch document deletion
  if doc.type is 'removed:placeholder' then return true
  if doc.type isnt 'entity' then return false
  # Do not index first entity document versions: it's just an entity scaffold
  # waiting to be edited
  if doc._rev.split('-')[0] is '1' then return false
  return true

onChange = (change)->
  { id, deleted, doc } = change
  _.info change, 'entity change'

  if deleted or doc.type is 'removed:placeholder'
    _.info id, 'DELETE'
    elastic.deleteById id
    return

  { claims } = doc

  # Known case: redirections
  unless claims?
    elastic.deleteById id
    return

  type = getEntityType claims['wdt:P31']
  if type in indexedTypes
    _.info id, 'INDEX'
    elastic.index type, id, doc
  else
    _.info [id, type], 'DELETE INVALID TYPE'
    elastic.deleteById id

module.exports = -> follow { dbBaseName, filter, onChange }
