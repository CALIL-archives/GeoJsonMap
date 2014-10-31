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
  createMap: (divId='map')->
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
    if not @map
      @createMap()
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
    @drawGeoJSON(shelfId)

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
    if type=='beacon'
#      log id
      return {
       fillColor: "#000000"
       fillOpacity : 1
       strokeWeight: 2
       zIndex: 1000
      }
  #・フロアと棚の色を変える (フロア番号・棚ID)
  #　　(アロア切り替えと棚の色を変える処理)
  loadFloorAndchangeShelfColor : (level, shelfId)->
    @loadFloorByLevel(level)
    @changeShelfColor(shelfId)

  # 指定した場所に現在地アイコンを表示
  #現在地を描画(minor)
  createUserLocation: (beaconId)->
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
    position = new google.maps.LatLng(lat/count, lon/count)
    if @userLocation
#      @userLocation.setPosition(position)
      @animateMarker([lat/count, lon/count])
    else
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
  drawingNumber : 100 # アニメーションのコマ数
  animationFrameTime : 10 # アニメーション１コマ描画時間
  animationCounter : 0 # カウンター
  startLatLng: undefined
  animateLatLng: undefined
  animationLat : undefined
  animationLng : undefined
  animateMarker : (goLatLng)->
    # スタート地点をセットする
    @startLatLng = [@userLocation.getPosition().lat(), @userLocation.getPosition().lng()]
    @transitionMarker(goLatLng)

  transitionMarker : (goLatLng) ->
    @animationCounter = 0
    @animateLatLng = @startLatLng
    # 1コマあたりの移動距離を求める
    @animationLat = (goLatLng[0] - @startLatLng[0]) / @drawingNumber
    @animationLng = (goLatLng[1] - @startLatLng[1]) / @drawingNumber
    @moveMarker()

  moveMarker : ->
    @animateLatLng[0] += @animationLat
    @animateLatLng[1] += @animationLng
    @userLocation.setPosition new google.maps.LatLng(@animateLatLng[0], @animateLatLng[1])
    if @animationCounter!=@drawingNumber
      @animationCounter++
      setTimeout =>
        @moveMarker()
      @animationFrameTime

  
  # 階層メニューの作成
  createLevelMenu: (levelArray)->
    $('#map-level').empty()
    for level in levelArray
      $('#map-level').append("""<li level="#{level}">#{level}</li>""")
    # 押した時のイベント設定
    $('#map-level li').mousedown ->
      # thisが必要なのでmapと書く
      map.loadFloorByLevel($(this).attr('level'))