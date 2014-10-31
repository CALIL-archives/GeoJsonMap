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

# 現在地の移動
setTimeout ->
  map.createUserLocation(165)
,2000

# 現在地の移動
setTimeout ->
  map.createUserLocation(166)
,3000
