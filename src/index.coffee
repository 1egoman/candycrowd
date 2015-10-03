###
 * candycrowd
 * https://github.com/1egoman/candycrowd
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

'use strict'

chalk = require "chalk"
path = require "path"
bodyParser = require "body-parser"


exports.main = ->

  # connect to database
  exports.connectToDB()
  
  app = require('express')()

  # set ejs as view engine
  app.set "view engine", "ejs"

  # include all the required middleware
  exports.middleware app

  # some sample routes
  app.get "/", (req, res) ->
      res.render "index"
  
  http = require('http').Server app
  io = require('socket.io') http

  io.on 'connection', (socket) ->
    console.log "connect"

  # listen for requests
  PORT = process.argv.port or 8000
  http.listen PORT, ->
    console.log chalk.blue "-> :#{PORT}"

exports.middleware = (app) ->

  
  # json body parser
  app.use bodyParser.json()
  

  
  # include sass middleware to auto-compile sass stylesheets
  node_sass = require "node-sass-middleware"
  app.use node_sass
    src: path.join(__dirname, "../public"),
    dest: path.join(__dirname, "../public"),
    debug: true
  

  # serve static assets
  app.use require("express-static") path.join(__dirname, '../public')


exports.connectToDB = ->
  require("./db") module.exports.mongouri or module.exports.db or "mongodb://user:password@example.com:port/database"


exports.main()
