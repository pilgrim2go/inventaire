#!/usr/bin/env coffee

# NEED to be executed from inventaire root
# folder to get the 'config'
# ex: ./scripts/upload_jpg.coffee ./imageFactory/images/my.jpg


CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require('builders', 'utils')
# this script is used to upload static images for both production and development
# thus, images have to go to the PROD container
CONFIG.swift.container = 'img'
require 'colors'
{ putImage } = __.require 'controllers', 'upload/upload'
cp = require 'copy-paste'
Promise = require 'bluebird'
fs = require 'fs'

imagesPaths = process.argv.slice(2)
imageMap = {}

uploadImg = (imagePath)->
  filename = imagePath.split('/').slice(-1)[0]
  console.log 'imagePath: '.green, imagePath
  console.log 'filename: '.green, filename
  putImage
    id: filename
    path: imagePath
    keepOldFile: true
  .then (res)->
    { id, url } = res
    url = "https://inventaire.io#{url}"
    cp.copy url
    console.log 'Copied to Clipboard: '.green, url
    imageMap[id] = url
  .catch _.Error('putImage err')


Promise.all imagesPaths.map(uploadImg)
.then ->
  path = './uploads_map.json'
  fs.writeFileSync path, JSON.stringify(imageMap, null, 4)
  _.info "#{path} saved"
  # process.exit 0
.catch _.Error('saving map err')
