# マップデータ
# #000101	#000176	#000177	#000162	#000178

# 地図=geojsonを切り替える
# 指定した棚の色を変える

# 現在地を消す

# get geojson
# メニューをつくる関数

# 図書館変わった時 地図の中心点を変える

#・図書館が変わった時
#・階層切替ボタンが押された時
#・棚の色を変えるために階が切り替わった時

# getGeojsonByLevel

log = (obj)->
  try:
    console.log(obj)

map =
  # マップのオブジェクト
  map : null
  # 現在位置のオブジェクト
  userLocation: null
  # geojsonオブジェクト
  geosjon: null
  init: (divId)->
    @map = new google.maps.Map(document.getElementById(divId),
      disableDefaultUI: true
      zoom: 19
      maxZoom: 32
      center:
        lat: 0
        lng: 0
      scaleControl: false,
  #    panControl: false
  #    zoomControl: false
  #    streetViewControl: false
  #    mapTypeControl: false 
    )
  # フロア切り替え
  loadFloorByLevel: (level)->
    # 現在位置の削除
    @removeUserLocation()
    @geojson = app.getGeoJSONByLevel(level)
    # レイヤーのオブジェクトを破棄する
    @map.data.forEach (feature)=>
      @map.data.remove feature
    # 地図の中心点を変える
    latlng = new google.maps.LatLng(@geojson.haika.xyLatitude, @geojson.haika.xyLongitude)
    @map.setCenter(latlng)
    # geojsonを描画する
    @map.data.addGeoJson(@geojson)
    @drawGeoJSON()

  # geojsonを描画する 
  drawGeoJSON : (shelfId=0)->
    @map.data.setStyle (feature) =>
      @applyStyle(feature, shelfId)
  # 棚の色を変える (棚ID)
  changeShelfColor: (shelfId)->
    drawGeoJSON(shelfId)

  # スタイルを適用する
  applyStyle : (feature, shelfId=0)->
    id   = feature.getProperty("id")
    type = feature.getProperty("type")
    if type=='floor'
      return {
       fillColor: "#ffffff"
       fillOpacity : 0.5
       strokeWeight: 0
       zIndex: -1
      }
    if type=='wall'
      return {
       fillColor: "#555555"
       fillOpacity : 1
       strokeWeight: 2
       strokeColor:"#555555"
       strokeOpacity:1
      }
    if type=='shelf'
      # 目的の棚だったらスタイルを変える
      if id==shelfId
        return {
         fillColor: "#ff0000"
         fillOpacity : 1
         strokeWeight: 3
        }
      else
        return {
         fillColor: "#aaaaff"
         fillOpacity : 1
         strokeWeight: 2
        }

  #・フロアと棚の色を変える (フロア番号・棚ID)
  #　　(アロア切り替えと棚の色を変える処理)
  loadFloorAndShowHighlight : (level, shelfId)->
    loadFloorByLevel(level)
    changeShelfColor(shelfId)

  # 指定した場所に現在地アイコンを表示
  #現在地を描画(minor)
  createUserLocation: (beaconId)->
    @removeUserLocation()
    lat = 0
    lon = 0
    count = 0
    for feature in @geojson.features
      if feature.properties.type=='beacon'
        if feature.properties.id==beaconId
          count = feature.geometry.coordinates[0].length
          for coordinate in feature.geometry.coordinates[0]
            lat += coordinate[1]
            lon += coordinate[0]
    if lat==0 and lon==0
      return
    markerImage = new google.maps.MarkerImage('img/marker.png',
      new google.maps.Size(34, 34),
      new google.maps.Point(0, 0),
      new google.maps.Point(17, 17))
    log lat/count
    log lon/count
    position = new google.maps.LatLng(lat/count, lon/count)
    @userLocation = new google.maps.Marker
      position: position
      map: @map
      icon: markerImage
    @userLocation.setMap(@map)

  # 現在地の表示を消す
  removeUserLocation: ()->
    if @userLocation
      @userLocation.setMap(null)
    @userLocation = null

  # マーカーのアニメーション
  animateMarker : (goLatLng)->
    drawingNumber = 100 # 描画回数
    delay = 10 # 描画時間
    counter = 0 # カウンター
    lat = undefined
    lng = undefined

    marker = map.userLocation

    #milliseconds
    transition = (result) ->
      counter = 0
      lat = (goLatLng[0] - animateLatLng[0]) / drawingNumber
      lng = (goLatLng[1] - animateLatLng[1]) / drawingNumber
      moveMarker()

    moveMarker = ->
      animateLatLng[0] += lat
      animateLatLng[1] += lng
      marker.setPosition new google.maps.LatLng(animateLatLng[0], animateLatLng[1])
      if counter!=drawingNumber
        counter++
        setTimeout moveMarker, delay

  
  # 階層メニューの作成
  createLevelMenu: (levelArray)->
    $('#map-level').empty()
    for level in levelArray
      $('#map-level').append("""<li level="#{level}">#{level}</li>""")
    # 押した時のイベント設定
    $('#map-level li').mousedown ->
      # thisが必要なのでmapと書く
      map.loadFloorByLevel($(this).attr('level'))

# マップの作成
map.init('map')


app =
  geojsons : {}
  getGeoJSONByLevel: (level)->
    geojson = @geojsons[level]
    # TODO:中心点を求める処理を入れる
    geojson.haika =
      xyLatitude: 35.1550682
      xyLongitude: 136.9637741
    return geojson
  loadGeoJSON : (option)->
    $.ajax
      url: """http://lab.calil.jp/haika_store/load.php?major=#{option.major}"""
      type: 'GET'
      cache: false
      dataType: 'json'
      error: ()=>
        option.error and option.error('データが読み込めませんでした')
      success: (data)=>
        option.success and option.success(data)
  initGeoJSON : (major)->
    @loadGeoJSON(
      major   : major
      success : (data)=>
        @geojsons = data.geojson
        levels = []
        for level, geojson of data.geojson
          levels.push(level)
        map.loadFloorByLevel(levels[0])
        map.createLevelMenu(levels.reverse())
      error   : (message)->
        alert(message)
    )

# フロアデータの呼び出し、majorを渡す
app.initGeoJSON(101)
setTimeout ->
  map.createUserLocation(164)
,1000

setTimeout ->
  map.createUserLocation(165)
,2000

setTimeout ->
  map.createUserLocation(166)
,3000


# マーカーの移動
moveMarker = ->
  lat = map.getCenter().lat()
  lng = map.getCenter().lng()
  count = 20
  moveMarker = ->
    lat = lat - 0.000005
    lng = lng + 0.000005
    marker.setPosition new google.maps.LatLng(lat, lng)
    count = count - 1
    if count > 0
      setTimeout moveMarker, 10
#  moveMarker()


position = [35.155001527242796, 136.96389599263 ]

accuracy = 100
delay = 10
i = 0
deltaLat = undefined
deltaLng = undefined

marker = map.userLocation

#milliseconds
transition = (result) ->
  i = 0
  deltaLat = (result[0] - position[0]) / accuracy
  deltaLng = (result[1] - position[1]) / accuracy
  moveMarker()

moveMarker = ->
  position[0] += deltaLat
  position[1] += deltaLng
  marker.setPosition new google.maps.LatLng(position[0], position[1])
  if i!=accuracy
    i++
    setTimeout moveMarker, delay


animateMarker = ->
  result = [marker.getPosition().lat(), marker.getPosition().lng()]
  transition(result)