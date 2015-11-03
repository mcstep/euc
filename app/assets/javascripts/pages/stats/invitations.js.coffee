$ ->
  $('.invitations-chart').each ->
    stats = $(this).data('stats')
    id    = $(this).attr('id')

    if stats
      AmCharts.makeChart id,
        type: 'serial'
        theme: 'light'
        categoryField: 'name'
        categoryAxis:
          gridPosition: 'start'
          gridAlpha: 0
          position: 'left'
        valueAxes: [
          stackType: 'regular'
          axisAlpha: 0.3
          gridAlpha: 0
        ]
        dataProvider: stats.data
        chartCursor:
          fullWidth: true
          cursorAlpha: 0.05
          graphBulletAlpha: 1
        graphs: [
          {
            type: 'step'
            title: 'Actual'
            balloonText: '[[title]]: [[value]]'
            valueField: 'actual'
            fillAlphas: 0.5
            color: '#000000'
          },
          {
            type: 'step'
            title: 'Cumulative'
            balloonText: '[[title]]: [[value]]'
            valueField: 'cumulative'
            fillAlphas: 0.5
            color: '#000000'
          }
        ]
        export:
          enabled: true
