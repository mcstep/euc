$ ->
  $('.sessions-chart').each ->
    stats = $(this).data('stats')
    id    = $(this).attr('id')

    if stats
      AmCharts.makeChart id,
        type: 'serial',
        theme: 'light',
        legend:
          horizontalGap: 10
          position: 'bottom'
          markerSize: 10
        categoryField: 'day'
        categoryAxis:
          parseDates: true
          gridPosition: 'start'
          position: 'left'
        dataProvider: stats.data
        graphs: [
          title: 'Session Length (minutes)'
          valueField: 'length'
          lineThickness: 3
          bullet: 'round'
          bulletSize: 7
        ]
        export:
          enabled: true