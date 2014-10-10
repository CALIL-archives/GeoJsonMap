#geojson = [
#  {
#    type: "Feature"
#    geometry:
#      type: "Point"
#      coordinates: [
#        -77.03238901390978
#        38.913188059745586
#      ]
#
#    properties:
#      title: "Mapbox DC"
#      description: "1714 14th St NW, Washington DC"
#      "marker-color": "#fc4353"
#      "marker-size": "large"
#      "marker-symbol": "monument"
#  }
#  {
#    type: "Feature"
#    geometry:
#      type: "Point"
#      coordinates: [
#        -122.414
#        37.776
#      ]
#
#    properties:
#      title: "Mapbox SF"
#      description: "155 9th St, San Francisco"
#      "marker-color": "#fc4353"
#      "marker-size": "large"
#      "marker-symbol": "harbor"
#  }
#  {
#    type: "Feature"
#    geometry:
#      type: "Polygon"
#      coordinates: [[
#        -122.414, 37.776
#        -123.414, 37.776
#        -123.414, 38.776
#        -122.414, 38.776
#        -122.414, 37.776
#      ]]
#  }
#]
#L.mapbox.map("map", "examples.map-i86nkdio").setView([35.9620124, 136.18660999999997], 4).featureLayer.setGeoJSON geojson

map = L.mapbox.map('map', 'examples.map-i86nkdio')
    .setView([35.9620124, 136.18660999999997], 30);

#// As with any other AJAX request, this technique is subject to the Same Origin Policy:
#// http://en.wikipedia.org/wiki/Same_origin_policy
#// So the CSV file must be on the same domain as the Javascript, or the server
#// delivering it should support CORS.
featureLayer = L.mapbox.featureLayer()
    .loadURL('http://lab.calil.jp/haika_store/data/000105.geojson')
    .addTo(map)