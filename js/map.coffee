# GeoJson on Google Map
# https://developers.google.com/maps/documentation/javascript/datalayer?hl=ja

# 実行環境 ローカルか？
isLocal = ->
  return location.protocol=='file:' or location.port!=''

google.maps.event.addDomListener window, 'load', ->
  # Mapの初期設定
  # 中心のlat, lonは今後geojsonから取得できるようにしたい
  window.map = new google.maps.Map($('#map')[0],
    zoom: 20
    center:
      lat: 35.9619654
      lng: 136.1863268
  )
  
  # Load a GeoJSON from the same server as our demo.
  if isLocal()
    map.data.loadGeoJson '/data/000105.geojson'
  else
    map.data.loadGeoJson 'http://lab.calil.jp/haika_store/data/000105.geojson'
