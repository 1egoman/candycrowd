###
 * candycrowd
 * https://github.com/1egoman/candycrowd
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
mongoose = require "mongoose"

module.exports = (host) ->
  # connect to mongo database
  mongoose.connect host
  # error?
  mongoose.connection.on 'error', console.error.bind(console, 'db error:')
  # success
  mongoose.connection.once 'open', ->
    console.log 'Connected To Mongo instance:', host
    return
  return
