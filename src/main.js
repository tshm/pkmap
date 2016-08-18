var app = Elm.Pkmap.fullscreen();

var map;
function initMap() {
  map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: -34.397, lng: 150.644},
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
  var circle = new google.maps.Circle({
    strokeColor: '#00FF00',
    strokeOpacity: 0.6,
    strokeWeight: 2,
    fillColor: '#00FF00',
    fillOpacity: 0.10,
    map: map,
    center: {lat: o.center.latitude, lng: o.center.longitude},
    radius: o.radius
  });
  circles.push( circle );
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

