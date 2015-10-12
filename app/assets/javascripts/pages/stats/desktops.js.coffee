$ ->
  $('.desktops-chart').each ->
    stats = $(this).data('stats')
    id    = $(this).attr('id')

    if stats

      AmCharts.makeChart id,
        type: 'serial'
        theme: 'light'
        categoryField: 'day'
        categoryAxis:
          parseDates: true
          gridPosition: 'start'
          gridAlpha: 0
          position: 'left'
        valueAxes: [
          stackType: 'regular'
          axisAlpha: 0.3
          gridAlpha: 0
          title: 'Launches'
        ]
        dataProvider: stats.data
        graphs: Object.keys(stats.kinds).map (k) ->
          type: 'column',
          balloonText: '[[title]]: [[value]]'
          valueField: k,
          title: stats.kinds[k],
          fillAlphas: 1,
          color: '#000000'
        export:
          enabled: true


$ ->
  $('.global-desktops-chart').each ->
    stats = $(this).data('stats')
    id    = $(this).attr('id')

    if stats

      AmCharts.makeChart id,
        type: 'serial'
        theme: 'light'
        categoryField: 'day'
        categoryAxis:
          parseDates: true
          gridPosition: 'start'
          gridAlpha: 0
          position: 'left'
        valueAxes: [
          axisAlpha: 0.3
          gridAlpha: 0
          title: 'Launches'
        ]
        dataProvider: stats.data
        graphs: Object.keys(stats.kinds).map (k) ->
          bullet: "round",
          bulletSize: 1,
          balloonText: '[[title]]: [[value]]'
          valueField: k,
          title: stats.kinds[k],
          fillAlphas: 0,
          lineAlphas: 1,
          color: '#000000'
        chartCursor:
          cursorPosition: 'mouse'
        export:
          enabled: true