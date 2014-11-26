$.extend map,
  canvasResize: ->
    if location.hash == '#map_view'
      canvasHeight = $(window).height() - ($('.header').height() + 1) - ($('.footer').height() + 1)
      $('#map-canvas').height(canvasHeight)
      # GoogleMapsAPIのリサイズイベント発火に失敗するので少し遅らせる
      setTimeout(=>
        center = @googleMaps.getCenter()
        google.maps.event.trigger(@googleMaps, 'resize')
        @googleMaps.setCenter(center)
      , 50)
    return

# ハッシュチェンジ, 画面回転, リサイズ イベントハンドラ
$(window).on 'hashchange orientationchange resize', -> map.canvasResize()