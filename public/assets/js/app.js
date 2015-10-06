  var map, us_location, us_lat, us_lng, types = [], all_houses = []

  // generate differing sized candy icons
  var candy_pin = []
  for (i = 1; i <= 11; i++) {
    candy_pin.push({
      path: 'M12.8,9.1C11.6,13.4,7,31,7,31S2.4,13.5,1.3,9.1C0.2,4.7,2.2,1,7,1S13.7,5.2,12.8,9.1z',
      fillColor: '#db9019',
      fillOpacity: 1,
      scale: 0.2 * i,
      strokeColor: '#c6c6c6',
      strokeWeight: 0,
      anchor: {x: 8, y: 30}
    })
  }

  // icon for an inactive house
  var inactive = {
    path: 'M 125,5 155,90 245,90 175,145 200,230 125,180 50,230 75,145 5,90 95,90 z',
    fillColor: 'red',
    fillOpacity: 1,
    scale: 0.1,
    strokeColor: 'red',
    strokeWeight: 2,
    anchor: {x: 8, y: 30}
  }


  // the icon for the user
  var user = {
    path: 'M64.8,38.2c0,5.3,5.6,26.2,3.9,30.5c-2.3,5.7-5.9,0.2-10.6-0.3c-4.8-0.5-10.5,2.8-15.2,2.8c-4,0-7.7-4.7-12.1-3.5c-5.5,1.5-9.9,6-12.2,0.8c-2-4.4-2.4-25-2.4-30.4c0-16.9,10.9-30.5,24.3-30.5S64.8,21.4,64.8,38.2z',
    fillColor: 'white',
    fillOpacity: 1,
    scale: 0.5,
    strokeColor: 'black',
    strokeWeight: 2,
    anchor: {x: 40, y: 30}
  }





  // round numbr
  round = function(n, decimals) {
      return Number((Math.round(n + "e" + decimals)  + "e-" + decimals));
  }



  // google map init
  initialize = function() {

    // make sure the geolocation api exists
    navigator.geolocation || $(".no-geo").css("display", "block")

    // get user's position
    navigator.geolocation.getCurrentPosition(function(geo) {

      // create the google map
      map = new google.maps.Map(document.getElementById('map'), {
      center: {
        lat: geo.coords.latitude,
        lng: geo.coords.longitude
      },
        zoom: 18
      });

      // put the ghost at our current position
      reset_map_center(geo)
      navigator.geolocation.watchPosition(reset_map_center)
      
      // get houses and put them on the map
      get_houses()

    }, function() {
      // no geolocation data
      $(".no-geo").css("display", "block")
    })
  }
  google.maps.event.addDomListener(window, 'load', initialize);

  // reset our location on the map
  reset_map_center = function(geo) {
    us_location && us_location.setMap(null)
    us_location = new google.maps.Marker({
      position: {
        lat: geo.coords.latitude,
        lng: geo.coords.longitude
      },
      map: map,
      icon: user
    })

    // set our coords for later
    us_lat = geo.coords.latitude,
    us_lng = geo.coords.longitude
  }


  open_rate_view = function() {
    $(".blurred-bg").css("display", "block")
    $(".rate-view").css("display", "block")
  }

  close_rate_view = function() {
    $(".blurred-bg").css("display", "none")
    $(".rate-view").css("display", "none")
  }

  is_old = function(i) {
    HOUR = 60 * 60 * 1000
    current = new Date().getTime()
    return i.last_updated + HOUR < current
  }



  var socket = io()
  socket.on("new:house:ack", function(p) {
    console.log("Got a response: "+JSON.stringify(p))
    get_houses()
  })

  // update houses on the map
  socket.on("get:house:ack", function(h) {
    /* $(".house-container").html(JSON.stringify(h, null, 2)) */
    /* console.log(h) */

    // clear all houses
    all_houses.forEach(function(i){ i.setMap(null)  })

    h.forEach(function(house) {
      marker = new google.maps.Marker({
        position: house,
        map: map,
        title: house.rating.toString(),
        icon: is_old(house) ? inactive : candy_pin[Math.floor(house.rating)]
      });

      // user wants more info on a house
      marker.addListener('click', function() {

        // update the modal
        $(".modal .selected-rating").html(house.rating / 10 * 100 + "%")
        $(".modal .selected-geo-lat").html(house.lat)
        $(".modal .selected-geo-lng").html(house.lng)

        // update types of candy
        if (house.types.indexOf("coco") !== -1) {
          $(".modal .selected-img-coco").css("display", "block")
        } else {
          $(".modal .selected-img-coco").css("display", "none")
        }

        // show modal
        $(".modal").modal("show")
      });
      all_houses.push(marker)
    })
  })

  // add a new house with the current location
  add_new_house = function(rating, type) {
    socket.emit("new:house", {
      rating: rating,
      types: types,
      lat: us_lat,
      lng: us_lng
    })
  }

  get_houses = function() {
    socket.emit("get:house")
  }

  new_house = function() {
    add_new_house(parseInt($(".ratings-box").val()), types)
    $(".main-view").css("display", "block")
    $(".rate-view").css("display", "none")
    $(".blurred-bg").css("display", "none")
  }

