url = """http://lab.calil.jp/haika_store/data/000105.geojson"""
$.ajax
  url: url
  type: "GET"
  cache : false
  dataType: "text"
  error: ()=>
    alert 'load error'
  success: (data)=>
#    log data
    geojson = JSON.parse(data)
    console.log(geojson.features)
    width = 1024
    height = 768
    projection = d3.geo.mercator().center([
      136.963791
      35.155080
    ]).translate([
      width / 2
      height / 2
    ]).scale(1500)

    # 緯度経度⇒パスデータ変換設定
    path = d3.geo.path().projection(projection)
    svg = d3.select("#map").append("svg").attr("width", width).attr("height", height)
    svg.append("g").selectAll("path").data(geojson.features).enter().append("path").attr "d", path


