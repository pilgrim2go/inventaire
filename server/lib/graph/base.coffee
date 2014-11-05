CONFIG = require 'config'
__ = CONFIG.root
_ = __.require('builders', 'utils')


levelgraph = require 'levelgraph'

Promise = require 'bluebird'

_g = require './graph_utils'


module.exports = (graphName)->

  if CONFIG.env is 'tests'
    level = require('level-test')()
    leveldb = level()
  else
    level = require 'level'
    dbPath = __.path 'leveldb', graphName

    leveldb = level(dbPath)

  graph = levelgraph(leveldb)

  action = (verb, args)->
    obj = _g.normalizeInterface(args, true)
    def = Promise.defer()
    _.logBlue obj, verb
    graph[verb] obj, (err, result)->
      if err then def.reject(err)
      else
        _.logGreen result, "#{verb}: success!"

        if result?
          result = _g.aliases.wrapAll(result)

        def.resolve(result)
    return def.promise

  getBidirectional = (args...)->
    query = _g.normalizeInterface(args)
    # EXPECT short form: s, p, o
    # EXPECT a subject and a predicate
    # RETURNS an array of subjet and/or object
    unless query.s? and query.p?
      return Promise.defer().reject('missing subject or predicate')

    query2 = _g.mirrorTriple(query)

    _.logBlue query, 'query1'
    _.logBlue query2, 'query2'

    # should rather reject as this method returns a promise, right?
    promise1 = @get query
    promise2 = @get query2
    return Promise.all([promise1, promise2])
    .spread (fromSubject, fromObject)->
      results1 = _g.pluck.objects(fromSubject)
      results2 = _g.pluck.subjects(fromObject)
      result = _.uniq results1.concat(results2)
      return _.logGreen result, 'bidirectional result'

  # PUT once with an arbitrary direction
  # getBidirectional or delBidirectional will find it
  # it should just be agreed that a type of relation
  # is a mutual relation
  # => putBidirectional aliased to graph.put

  delBidirectional = (args...)->
    triples = _g.normalizeInterface(args)
    return @del _g.addMirrorTriples(triples)

  API =
    # query example: { subject: "a", limit: 4, offset: 2, filter: ()-> }
    get: (args...)-> action 'get', args
    put: (args...)-> action 'put', args
    del: (args...)-> action 'del', args
    getBidirectional: getBidirectional
    delBidirectional: delBidirectional
    utils: _g
    leveldb: leveldb
    logDb: _g.logDb
    graph: graph

  API.putBidirectional = API.put

  return API