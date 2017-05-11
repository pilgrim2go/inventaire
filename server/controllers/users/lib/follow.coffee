# Update ElasticSearch entities index, with ElasticSearch type corresponding
# to entities own types when available
CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
follow = __.require 'lib', 'follow'
dbBaseName = 'users'
typeName = 'user'
elastic = __.require('lib', 'elastic_api')(dbBaseName)
{ public:publicAttributes } = __.require 'models', 'attributes/user'
# Omit snapshot as it contains private and semi priavte data
publicAttributesStrict = _.without publicAttributes, 'snapshot'

filter = (doc)-> doc.type is 'user' or doc.type is 'deletedUser'

onChange = (change)->
  { id, deleted, doc } = change
  _.warn change, 'user change'

  if deleted or doc.type is 'deletedUser'
    _.warn id, 'user deleted'
    elastic.deleteById id
  else
    _.warn id, 'user indexed'
    elastic.index typeName, id, _.pick(doc, publicAttributesStrict)

module.exports = -> follow { dbBaseName, filter, onChange }
