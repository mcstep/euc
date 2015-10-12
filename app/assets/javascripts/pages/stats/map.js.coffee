$ ->
  stats = $('#map-chart').data('stats')

  if stats
    minBulletSize = 20
    maxBulletSize = 70
    min = Infinity
    max = -Infinity

    # get min and max values
    for stat in stats
      min = stat.value if stat.value < min
      max = stat.value if stat.value > max

    # build map
    AmCharts.ready ->
      dataProvider = 
        map: "worldLow"
        images: []

      # create circle for each country
      # it's better to use circle square to show difference between values, not a radius
      maxSquare = maxBulletSize * maxBulletSize * 2 * Math.PI
      minSquare = minBulletSize * minBulletSize * 2 * Math.PI

      # create circle for each country
      for stat in stats
        id = stat.code

        if countries[id]
          # calculate size of a bubble
          square = (stat.value - min) / (max - min) * (maxSquare - minSquare) + minSquare
          square = minSquare if square < minSquare
          square = maxSquare unless square
          size   = Math.sqrt(square / (Math.PI * 2))

          dataProvider.images.push
            type: 'circle'
            width: size
            height: size
            longitude: countries[id].long
            latitude: countries[id].lat
            color: countries[id].color
            title: countries[id].name
            value: stat.value

      map = new AmCharts.AmMap(AmCharts.themes.dark)
      map.areasSettings = {
        unlistedAreasColor: "#000000",
        unlistedAreasAlpha: 0.1
      }
      map.imagesSettings.balloonText = "<span style='font-size:14px;'><b>[[title]]</b>: [[value]]</span>";
      map.dataProvider = dataProvider;
      map.export = { enabled: true };
      map.write('map-chart')