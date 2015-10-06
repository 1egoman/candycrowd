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

House = require "./models/house"


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

  # socket.io
  io.on 'connection', (socket) ->
    console.log chalk.cyan "connection from socket.io"



    # add a new house
    # format of {
    #   rating: 0-10,
    #   lat: 0,
    #   lng: 0
    # }
    DIST_THRES = 12/111093
    socket.on "new:house", (payload) ->
      console.log "new house addition", payload

      # is there a house in the local region? Within DIST_THRES?
      House.findOne
        lat:
          $lt: payload.lat+DIST_THRES
          $gt: payload.lat-DIST_THRES
        lng:
          $lt: payload.lng+DIST_THRES
          $gt: payload.lng-DIST_THRES
      , (err, house) ->
        if err
          socket.emit "new:house:ack", err


        # there isn't a new house there
        else if house is null
          payload.num_p = 1
          payload.last_updated = new Date().getTime()
          new House(payload)
          .save (err) ->
            if err
              socket.emit "new:house:ack", err
            else
              socket.emit "new:house:ack", status: "ok"

        # there is already a house
        else
          house.rating = ((house.rating * house.num_p) + payload.rating) / (house.num_p+1)
          house.num_p += 1
          house.last_updated = new Date().getTime()
          house.types = house.types.concat payload.types
          console.log house.types, payload.types

          house.save (err) ->
            socket.emit "new:house:ack", err or status: "ok"










    # get all houses
    # how big to search inside, in degrees
    # 0.15 is a pretty good balance I think
    SEARCH_RADIUS = 0.15
    socket.on "get:house", (payload) ->
      if payload.lat and payload.lng
        House.find
          lat:
            $lt: payload.lat+SEARCH_RADIUS
            $gt: payload.lat-SEARCH_RADIUS
          lng:
            $lt: payload.lng+SEARCH_RADIUS
            $gt: payload.lng-SEARCH_RADIUS
        , (err, houses) ->
          # console.log houses
          if err
            socket.emit "get:house:ack", err
          else
            socket.emit "get:house:ack", houses
            socket.broadcast.emit "get:house:ack", houses









  # listen for requests
  PORT = process.env.PORT or 8000
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
  require("./db") module.exports.mongouri or module.exports.db or "mongodb://cc:cc@ds029224.mongolab.com:29224/candycrowd"


exports.main()
