# Update ElasticSearch entities index, with ElasticSearch type corresponding
# to entities own types when available
CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
follow = __.require 'lib', 'follow'
dbBaseName = 'groups'
typeName = 'group'
elastic = __.require('lib', 'elastic_api')(dbBaseName)

# Do not filter-out doc.searchable=false so that toggling this settings
# does update the document in ElasticSearch and can then be filtered-out
# at search time
filter = (doc)-> doc.type is 'group'

onChange = (change)->
  { id, deleted, doc } = change
  _.info change, 'group change'

  if deleted or not doc.searchable
    _.info id, 'group deleted'
    elastic.deleteById id
  else
    _.info id, 'group indexed'
    elastic.index typeName, id, doc

module.exports = -> follow { dbBaseName, filter, onChange }
