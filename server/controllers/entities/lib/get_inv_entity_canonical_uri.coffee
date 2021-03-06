# A canonical URI is the prefered URI to refer to an entity,
# typically, an isbn: URI rather than an inv: one
# Those URIs are the only URIs used to bound items to entities and
# in entities claims, and are used in the client to build entities URLs
# to which alias URIs redirect
# Ex: /entity/inv:#{invId} redirects to /entity/isbn:#{isbn}
__ = require('config').universalPath
{ normalizeIsbn } = __.require 'lib', 'isbn/isbn'
error_ = __.require 'lib', 'error/error'

module.exports = (entity)->
  { _id:invId, redirect } = entity

  unless invId? then throw error_.new 'missing id', 500, entity

  invUri = "inv:#{invId}"

  # Case when the entity document is simply a redirection to another entity
  # signaled via the 'redirect' attribute on the entity document
  if redirect?
    redirectsObj =
      from: invUri
      to: redirect
    return [ redirect, redirectsObj ]

  # Case when the entity document is a proper entity document
  # but has a more broadly recognized URI available, currently only an ISBN
  isbn = entity.claims['wdt:P212']?[0]

  # Those URIs are aliases but, when available, always use the canonical id,
  # that is, in the only current, the ISBN
  # By internal convention, ISBN URIs are without hyphen
  if isbn? then uri = "isbn:#{normalizeIsbn(isbn)}"
  else uri = invUri

  redirectsObj = null
  if uri isnt invUri
    redirectsObj =
      from: invUri
      to: uri

  return [ uri, redirectsObj ]
