/*global Elm initMap google DEBUG */
var app = Elm.Pkmap.fullscreen();
var map, marker, circles = [];

app.ports.initMap.subscribe(function( o ) {
  if ( !o ) return;
  if ( DEBUG ) { console.log('initMap', o ); }
  map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: 0.0, lng: 0.0},
    zoom: 17
  });
  marker = new google.maps.Marker({
    position: map.getCenter(),
    icon: {
      path: google.maps.SymbolPath.CIRCLE,
      strokeColor: '#8888FF',
      scale: 5
    },
    opacity: 0.8,
    draggable: false,
    map: map
  });
});

app.ports.locationChange.subscribe(function( loc ) {
  if ( !loc ) return;
  if ( DEBUG ) { console.log('move', loc ); }
  var position = { lat: loc.latitude, lng: loc.longitude };
  map.panTo( position );
  marker.setPosition( position );
});

app.ports.addCircle.subscribe(function( o ) {
  if ( !o ) return;
  if ( DEBUG ) { console.log('add', o ); }
  // if ( DEBUG ) { o.center.latitude += 0.001 * circles.length; }
  var circleProp = {
    strokeColor: '#FF0000',
    strokeOpacity: 0.2,
    strokeWeight: 20,
    fillOpacity: 0.0,
    map: map,
    center: {lat: o.center.latitude, lng: o.center.longitude},
    radius: o.radius
  };
  if ( circles.length == 0 ) {
    circleProp = Object.assign( circleProp, {
      strokeColor: '#00FF00',
      strokeOpacity: 0.6,
      strokeWeight: 2,
      fillColor: '#00FF00',
      fillOpacity: 0.10
    });
  }
  circles.push( new google.maps.Circle( circleProp ));
  if ( DEBUG ) { console.log('circles', circles ); }
});

app.ports.removeCircle.subscribe(function( o ) {
  if ( !o ) return;
  if ( DEBUG ) { console.log('remove', o ); }
  var c = circles.pop();
  c.setMap( null );
});

app.ports.resetCircle.subscribe(function( o ) {
  if ( !o ) return;
  if ( DEBUG ) { console.log('reset', o ); }
  circles.forEach(function(o) {
    o.setMap( null );
  });
  circles.splice( 0, circles.length );
  if ( DEBUG ) { console.log('circles', circles ); }
});

