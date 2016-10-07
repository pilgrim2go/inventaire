#!/usr/bin/env coffee

# HOW TO
# From time to time, you can replace src/fullkey/en by {}
# and browse all the website to regenerate an updated list of the fullkeys

# Command: cd ~/inventaire && ./server/lib/emails/i18n/src/generate_lang_json.coffee all

{ red, grey } = require 'chalk'
console.time grey('total')
require('./lib/validate_cwd') process.cwd()
Promise = require 'bluebird'
extendLangWithDefault = require './lib/extend_lang_with_default'

args = process.argv.slice(2)
langs = require('./lib/validate_lang') args

console.time grey('generate')

Promise.all langs.map(extendLangWithDefault)
.then ->
  console.timeEnd grey('generate')
  console.timeEnd grey('total')
.catch (err)-> console.log red('global err'), err.stack
