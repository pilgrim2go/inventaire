CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
promises_ = __.require 'lib', 'promises'
{ catchNotFound } = __.require 'lib', 'error/error'
{ host:elasticHost } = CONFIG.elasticsearch

# TODO: regroup requests and use ElasticSearch Bulk API
module.exports = (dbBaseName)->
  dbName = CONFIG.db.name dbBaseName
  base = "#{elasticHost}/#{dbName}"

  return API =
    index: (type, id, doc)->
      _.log arguments, 'index'
      # doc._id should be deleted so that ElasticSearch doesn't answer
      # "Field [_id] is a metadata field and cannot be added inside a document"
      delete doc._id
      promises_.put
        url: "#{base}/#{type}/#{id}",
        body: doc
      .catch _.Error("#{type} index err: #{id}")

    # Delete without knowning the type
    deleteById: (id)->
      _.log arguments, 'delete'
      promises_.get "#{base}/_all/#{id}"
      .then (res)->
        { _type } = res
        promises_.delete "#{base}/#{_type}/#{id}"
      # Ignore not found, its already deleted
      # Known case: on follow reset, changes callback
      .catch catchNotFound
      .catch _.Error("delete err: #{id}")
