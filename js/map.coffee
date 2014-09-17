google.maps.event.addDomListener window, 'load', ->
  window.map = new google.maps.Map(document.getElementById('map-canvas'),
    zoom: 20
    maxZoom: 28
    center:
      lat: 35.9619654
      lng: 136.1863268
  )
  map.data.loadGeoJson 'http://lab.calil.jp/haika_store/data/000105.geojson'
  map.data.setStyle (feature) ->
    type = feature.getProperty("type")
    if type=='floor'
      return {
       fillColor: "#ffffff"
       fillOpacity : 0.5
       strokeWeight: 0
      }
    else if type=='wall'
      return {
       fillColor: "#555555"
       fillOpacity : 1
       strokeWeight: 2
       strokeColor:"#555555"
       strokeOpacity:1
      }
    else
      return {
       fillColor: "#aaaaff"
       fillOpacity : 1
       strokeWeight: 2

      }

