###
 * candycrowd
 * https://github.com/1egoman/candycrowd
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

mongoose = require 'mongoose'

schema = mongoose.Schema
  rating: Number
  num_p: Number

  lat: Number
  lng: Number

module.exports = mongoose.model 'House', schema
