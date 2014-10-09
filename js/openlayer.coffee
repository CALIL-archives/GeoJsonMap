styles =
  MultiPolygon: [new ol.style.Style(
    stroke: new ol.style.Stroke(
      color: "yellow"
      width: 1
    )
    fill: new ol.style.Fill(color: "rgba(255, 255, 0, 0.1)")
  )]
  Polygon: [new ol.style.Style(
    stroke: new ol.style.Stroke(
      color: "blue"
#      lineDash: [4]
      width: 3
    )
    fill: new ol.style.Fill(color: "rgba(0, 0, 255, 0.1)")
  )]
  GeometryCollection: [new ol.style.Style(
    stroke: new ol.style.Stroke(
      color: "magenta"
      width: 2
    )
    fill: new ol.style.Fill(color: "magenta")
    image: new ol.style.Circle(
      radius: 10
      fill: null
      stroke: new ol.style.Stroke(color: "magenta")
    )
  )]
  Circle: [new ol.style.Style(
    stroke: new ol.style.Stroke(
      color: "red"
      width: 2
    )
    fill: new ol.style.Fill(color: "rgba(255,0,0,0.2)")
  )]

###*
@type {olx.source.GeoJSONOptions}
###
vectorSource = new ol.source.GeoJSON((object:
  type: "FeatureCollection"
  crs:
    type: "name"
    properties:
      name: "EPSG:3857"

  features: [
    {
      type: "Feature"
      geometry:
        type: "Point"
        coordinates: [
          0
          0
        ]
    }
    {
      type: "Feature"
      geometry:
        type: "LineString"
        coordinates: [
          [
            4e6
            -2e6
          ]
          [
            8e6
            2e6
          ]
        ]
    }
    {
      type: "Feature"
      geometry:
        type: "LineString"
        coordinates: [
          [
            4e6
            2e6
          ]
          [
            8e6
            -2e6
          ]
        ]
    }
    {
      type: "Feature"
      geometry:
        type: "Polygon"
        coordinates: [[
          [
            -5e6
            -1e6
          ]
          [
            -4e6
            1e6
          ]
          [
            -3e6
            -1e6
          ]
        ]]
    }
    {
      type: "Feature"
      geometry:
        type: "MultiLineString"
        coordinates: [
          [
            [
              -1e6
              -7.5e5
            ]
            [
              -1e6
              7.5e5
            ]
          ]
          [
            [
              1e6
              -7.5e5
            ]
            [
              1e6
              7.5e5
            ]
          ]
          [
            [
              -7.5e5
              -1e6
            ]
            [
              7.5e5
              -1e6
            ]
          ]
          [
            [
              -7.5e5
              1e6
            ]
            [
              7.5e5
              1e6
            ]
          ]
        ]
    }
    {
      type: "Feature"
      geometry:
        type: "MultiPolygon"
        coordinates: [
          [[
            [
              -5e6
              6e6
            ]
            [
              -5e6
              8e6
            ]
            [
              -3e6
              8e6
            ]
            [
              -3e6
              6e6
            ]
          ]]
          [[
            [
              -2e6
              6e6
            ]
            [
              -2e6
              8e6
            ]
            [
              0
              8e6
            ]
            [
              0
              6e6
            ]
          ]]
          [[
            [
              1e6
              6e6
            ]
            [
              1e6
              8e6
            ]
            [
              3e6
              8e6
            ]
            [
              3e6
              6e6
            ]
          ]]
        ]
    }
    {
      type: "Feature"
      geometry:
        type: "GeometryCollection"
        geometries: [
          {
            type: "LineString"
            coordinates: [
              [
                -5e6
                -5e6
              ]
              [
                0
                -5e6
              ]
            ]
          }
          {
            type: "Point"
            coordinates: [
              4e6
              -5e6
            ]
          }
          {
            type: "Polygon"
            coordinates: [[
              [
                1e6
                -6e6
              ]
              [
                2e6
                -4e6
              ]
              [
                3e6
                -6e6
              ]
            ]]
          }
        ]
    }
  ]
))
styleFunction = (feature, resolution) ->
  styles[feature.getGeometry().getType()]
url = """http://lab.calil.jp/haika_store/data/000105.geojson"""
$.ajax
  url: url
  type: "GET"
  cache : false
  dataType: "json"
  error: ()=>
    alert 'load error'
  success: (geojson)=>
    console.log geojson
    console.log geojson.features[0].geometry.coordinates
    features = []
    for object in geojson.features
      coordinates = []
      for geometry in object.geometry.coordinates[0]
        coordinate = ol.proj.transform(geometry, "EPSG:4326", "EPSG:3857")
        coordinates.push(coordinate)
        data =
          "type": "Feature"
          "geometry":
            "type": "Polygon",
            "coordinates": [
              coordinates
            ]
          "properties": object.properties
        features.push(data)
    console.log features
    geojson = 
      object:
        type: "FeatureCollection"
        'crs' :
          'type': 'name'
          'properties':
            'name': "EPSG:3857"
        features: features
#        features: [
#          {
#          type: "Feature"
#          geometry:
#            type: "Polygon"
#            coordinates: [new_cordinate]
#          },
#          {
#          type: "Feature"
#          geometry:
#            type: "Polygon"
#            coordinates: [[
#              [
#                -5e6
#                -1e6
#              ]
#              [
#                -4e6
#                1e6
#              ]
#              [
#                -3e6
#                -1e6
#              ]
#            ]]
#          }
#        ]
    console.log geojson
    vectorLayer = new ol.layer.Vector
      source: new ol.source.GeoJSON(geojson)
#      source: vectorSource
      style: styleFunction
#    window.view = new ol.View(
#        projection: "EPSG:3857"
#        maxZoom: 28
#        minZoom: 2
#    )
    window.map = new ol.Map(
      layers: [
        new ol.layer.Tile(source: new ol.source.OSM())
        vectorLayer
      ]
#      view : view
      target: "map"
      controls: ol.control.defaults(attributionOptions: (
        collapsible: false
      ))
      view: new ol.View(
        center: ol.proj.transform([136.18660999999997, 35.9620124], "EPSG:4326", "EPSG:3857")
        zoom: 20
      )
    )

# Set the stroke width, and fill color for each polygon
#featureStyle = {
#  fillColor: 'orange',
#  strokeWeight: 1
#}
#map.data.setStyle(featureStyle)
#features = map.data.addGeoJson(haika.createGeoJson())

