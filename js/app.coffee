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
    geojson = app.getGeoJSONByLevel(level)
    # レイヤーのオブジェクトを破棄する
    @map.data.forEach (feature)=>
      @map.data.remove feature
    # 地図の中心点を変える
    latlng = new google.maps.LatLng(geojson.haika.xyLatitude, geojson.haika.xyLongitude)
    @map.setCenter(latlng)
    # geojsonを描画する
    @map.data.addGeoJson(geojson)
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
  #・現在地を描画(minor)
  moveUserLocation: (beaconId)->
    
  #・現在地の表示を消す
  removeUserLocation: ()->

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
    geojson.haika =
      xyLatitude: 35.1550682
      xyLongitude: 136.9637741
    return geojson
  loadGeoJSON : (option)->
    $.ajax
      url: """http://lab.calil.jp/haika_store/load.php?major=#{option.major}"""
      type: 'POST'
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

# マーカーの設置
createMarker = ->
  markerImage = new google.maps.MarkerImage('img/marker.png',
    new google.maps.Size(34, 34),
    new google.maps.Point(0, 0),
    new google.maps.Point(17, 17))
  window.marker = new google.maps.Marker
    position:map.getCenter()
    map: map
    icon: markerImage # アイコン画像を指定
  marker.setMap(map);
#  marker.setAnimation(google.maps.Animation.BOUNCE);
#  marker.setMap(null);
#    draggable: true
#  google.maps.event.addListener centerMarker, "dragend", =>
#    log 'centerMarker'
#    position = centerMarker.getPosition()

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



