__ = require('config').universalPath
_ = __.require 'builders', 'utils'

ActionsControllers = __.require 'lib', 'actions_controllers'

module.exports =
  get: ActionsControllers
    authentified:
      'by-ids': require './by_ids'
      'by-score': require './by_score'
      'by-suspect-uris': require './by_suspect_uris'

  post: ActionsControllers
    admin:
      'collect-entities': require './collect_entities'

  put: ActionsControllers
    authentified:
      'update': require './update'
