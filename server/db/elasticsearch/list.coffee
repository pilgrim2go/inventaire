CONFIG = require 'config'
__ = CONFIG.universalPath

# Using CouchDB database names + environment suffix as indexes names
indexesBaseNameList = [
  'entities'
  'users'
  'groups'
]

indexesNameList = indexesBaseNameList.map (name)-> CONFIG.db.name name

module.exports = { indexesNameList }
