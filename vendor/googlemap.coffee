log = (obj)->
  try:
    console.log(obj)

map =
  # マップのオブジェクト
  googleMaps : null
  # ユーザーの現在地のオブジェクト
  userLocation: null
  # 目的地のオブジェクト
  destLocation: null
  # geojsonオブジェクト
  geosjon: null
  initDeferred: new $.Deferred
  createMap: (divId='map-canvas', zoom=20)->
    if @googleMaps
      return
    options = {
      zoom: zoom
      maxZoom: 38
      center: new google.maps.LatLng(-34.397, 150.644)
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true
      scaleControl: false
    }
    @googleMaps = new google.maps.Map(document.getElementById(divId), options)
    @initDeferred.resolve().promise() # 初期化完了を通知
    return
  
  # 処理の非同期化
  deferred: (process)->
    d = new $.Deferred()
    setTimeout(->
      process?()
      d.resolve()
      return
    , 0)
    return d.promise()

  # フロア切り替え
  loadFloorByLevel: (level, shelfId=0)->
    start_time = new Date()
    @createMap()
    geoJsonWithoutBeacon = null
    $.when(
      @deferred(=>
        # ボタンへ反映
        $('#map-level > li').css({'color': '#000000', 'background-color': '#FFFFFF'})
        $("#map-level > li[level='#{level}']").css({'color': '#FFFFFF', 'background-color': '#00BFFF'})
      ),@deferred(=>
        # 古いマップの削除
        @beforeBeaconId = 0
        @beforeShelfId = 0
        @userLocation = @removeMarker(@userLocation)
        @destLocation = @removeMarker(@destLocation)
        @googleMaps.data.forEach (feature)=>
          @googleMaps.data.remove feature
      ),@deferred(=>
        # 取得
        @geojson = app.getGeoJSONByLevel(level)
        geoJsonWithoutBeacon = @removeBeaconFromGeoJSON(@geojson)
      )
    ).done(=>
      # 新マップの描画
      @googleMaps.setCenter(new google.maps.LatLng(@geojson.haika.xyLatitude, @geojson.haika.xyLongitude))
      @googleMaps.data.addGeoJson(geoJsonWithoutBeacon)
      @applyStyle(shelfId)
      return
    )

  # geojsonからビーコンを除く
  removeBeaconFromGeoJSON : (geojson)->
    newGeoJSON = {
      type: "FeatureCollection",
      features : []
    }
    for feature in geojson.features
      if feature.properties.type!='beacon'
        newGeoJSON.features.push(feature)
    return newGeoJSON
  
  # フロアと棚の色を変える (フロア番号・棚ID)
  loadFloorAndChangeShelfColor: (level, shelfId)->
    @loadFloorByLevel(level, shelfId)

  # 棚の色を変える (棚ID)
  changeShelfColor: (shelfId)->
    @applyStyle(shelfId)

  # スタイルを適用する
  applyStyle : (shelfId=0)->
    @googleMaps.data.revertStyle()
    @googleMaps.data.setStyle (feature)=>
      type = feature.getProperty("type")
      id   = feature.getProperty("id")
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
           fillColor: "#FE0703"
           fillOpacity : 1
           strokeWeight: 1
          }
        else
          return {
           fillColor: "#CEE1F2"
           fillOpacity : 1
           strokeWeight: 1
          }
  #    if type=='beacon'
  #      return {
  #       fillColor: "#000000"
  #       fillOpacity : 0
  #       strokeWeight: 0
  #       zIndex: 1000
  #      }

  # オブジェクトの中心点を求める
  getObjectCenterLatLng: (objectId)->
    lat = 0
    lng = 0
    count = 0
    for feature in @geojson.features
#      if feature.properties.type=='beacon'
      if feature.properties.id==objectId
        count = feature.geometry.coordinates[0].length
        for coordinate in feature.geometry.coordinates[0]
          lat += coordinate[1]
          lng += coordinate[0]
    if lat==0 and lng==0
      return null
    else
      return {'lat': lat/count, 'lng': lng/count}
  beforeBeaconId : 0
  # 指定した場所に現在地アイコンを表示
  # 現在地を描画(minor)
  createUserLocation: (beaconId, markerType='marker')->
    # 同じ場所を連続して描くのを防ぐ
    if @userLocation and @beforeBeaconId==beaconId
      return
    else
      @beforeBeaconId=beaconId
    if @userLocation
      objectCenter = @getObjectCenterLatLng(beaconId)
      if not objectCenter
        # マーカーの削除
        @userLocation = @removeMarker(@userLocation)
        return
      @animateMarker([objectCenter.lat, objectCenter.lng])
    else
      @userLocation = @createMarker(beaconId, markerType)
    if @userLocation
      @userLocation.setMap(@googleMaps)
 
  beforeShelfId : 0
  # 指定した棚に目的地アイコンを表示
  # 目的地を描画(minor)
  createDestLocation: (shelfId, markerType='destination-infowindow')->
    # 同じ場所を連続して描くのを防ぐ
    if @destLocation and @beforeShelfId==shelfId
      return
    else
      @beforeShelfId=shelfId
    @destLocation = @removeMarker(@destLocation)
    @destLocation = @createMarker(shelfId, markerType)
    if @destLocation
      @destLocation.setMap(@googleMaps)

  iconMarker : ->
    new google.maps.MarkerImage('img/marker.png',
      new google.maps.Size(34, 34),
      new google.maps.Point(0, 0),
      new google.maps.Point(17, 17))
  iconMarkerWindow : ->
    new google.maps.MarkerImage('img/marker-infowindow.png',
      new google.maps.Size(73, 85),
      new google.maps.Point(0, 0),
      new google.maps.Point(38, 68))
  iconDest : ->
    new google.maps.MarkerImage('img/destination.png',
        new google.maps.Size(23, 30),
        new google.maps.Point(0, 0),
        new google.maps.Point(11, 30))
  iconDestWindow : ->
    new google.maps.MarkerImage('img/destination-infowindow.png',
        new google.maps.Size(74, 85),
        new google.maps.Point(0, 0),
        new google.maps.Point(38, 85))
  getIcon : (markerType)->
    if markerType=='marker'
      return @iconMarker()
    if markerType=='marker-infowindow'
      return @iconMarkerWindow()
    if markerType=='destination'
      return @iconDest()
    if markerType=='destination-infowindow'
      return @iconDestWindow()

  # マーカーの作成
  createMarker: (objectId, markerType)->
    objectCenter = @getObjectCenterLatLng(objectId)
    if not objectCenter
      return null
    position = new google.maps.LatLng(objectCenter.lat, objectCenter.lng)
    marker =  new google.maps.Marker
      position: position
      map: @googleMaps
      icon: @getIcon(markerType)
    return marker
  
  # マーカーの種類を変更する
  changeMarkerIcon : (marker, markerType)->
    # マーカーのアイコンを変更
    marker.setIcon(@getIcon(markerType))
  
  # マーカーを消す
  removeMarker: (marker)->
    if marker
      marker.setMap(null)
    return null
  
  # 現在地を消す
  removeUserLocation: ()->
    if @userLocation
      @userLocation = @removeMarker(@userLocation)

  # マーカーのアニメーション
  drawingNumber : 50 # アニメーションのコマ数
  animationFrameTime : 7 # アニメーション１コマ描画時間
  animationCounter : 0 # カウンター
  startLatLng: undefined
  animateLatLng: undefined
  animationLat : undefined
  animationLng : undefined
  animateMarker : (goLatLng)->
    if not @userLocation
      return
    # マーカーの吹き出しを消す
    @changeMarkerIcon(@userLocation, 'marker')
    # スタート地点をセットする
    @startLatLng = [@userLocation.getPosition().lat(), @userLocation.getPosition().lng()]
    @animationCounter = 0
    @animateLatLng = @startLatLng
    # 1コマあたりの移動距離を求める
    @animationLat = (goLatLng[0] - @startLatLng[0]) / @drawingNumber
    @animationLng = (goLatLng[1] - @startLatLng[1]) / @drawingNumber
    @moveMarker()

  moveMarker : ->
    if not @userLocation
      return
    @animateLatLng[0] += @animationLat
    @animateLatLng[1] += @animationLng
    @userLocation.setPosition new google.maps.LatLng(@animateLatLng[0], @animateLatLng[1])
    if @animationCounter==@drawingNumber
      # マーカーの吹き出しを出す
      @changeMarkerIcon(@userLocation, 'marker-infowindow')
    else
      @animationCounter++
      setTimeout( =>
        @moveMarker()
      , @animationFrameTime)

  
  # 階層メニューの作成
  createLevelMenu: (levelArray)->
    $('#map-level').empty()
    for level in levelArray
      $('#map-level').append("""<li level="#{level}">#{level}</li>""")
    # 押した時のイベント設定
    $('#map-level li').mousedown ->
      level = $(this).attr('level')
      # thisが必要なのでmapと書く
      map.loadFloorByLevel(level)
