/*global Elm */
var app = Elm.Pkmap.fullscreen();

var map;
function initMap() {
  map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: 0.0, lng: 0.0},
    zoom: 17
  });
}

app.ports.locationChange.subscribe(function( loc ) {
  if ( !loc ) return;
  if ( DEBUG ) { console.log('move', loc ); }
  map.panTo({lat: loc.latitude, lng: loc.longitude});
});

var circles = [];
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

app.ports.resetCircle.subscribe(function( o ) {
  if ( !o ) return;
  if ( DEBUG ) { console.log('reset', o ); }
  circles.forEach(function(o) {
    o.setMap( null );
  });
  circles.splice( 0, circles.length );
  if ( DEBUG ) { console.log('circles', circles ); }
});

