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
        # TODO: いまいる階を指定する
        map.loadFloorByLevel(levels[0])
        map.createLevelMenu(levels.reverse())
      error   : (message)->
        alert(message)
    )


## テストコード

# フロアデータの呼び出し、majorを渡す
app.initGeoJSON(101)

# 地下

time = 0
setTimeout ->
  map.createUserLocation(164)
,time+=1000
# 現在地の移動
setTimeout ->
  map.createUserLocation(165)
,time+=1000

# 現在地の移動
setTimeout ->
  map.createUserLocation(166)
,time+=1000

# 3Fへ移動
beaconId = 300
setTimeout ->
  map.loadFloorAndchangeShelfColor('3F', 299)
  time = 0
  setLocation()
,time+=1000

# 現在地の移動
setLocation = ()->
  setTimeout ->
    beaconId += 10
    map.createUserLocation(beaconId)
    if beaconId<385
      setLocation()
  , time+=500


