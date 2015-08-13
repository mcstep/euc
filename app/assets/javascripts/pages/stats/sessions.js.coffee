$ ->
  stats = $('#sessions-chart').data('stats')

  if stats
    AmCharts.makeChart 'sessions-chart',
      type: 'serial',
      theme: 'light',
      legend:
        horizontalGap: 10
        maxColumns: 1
        position: 'right'
        useGraphSettings: true
        markerSize: 10
      categoryField: 'day'
      categoryAxis:
        parseDates: true
        gridPosition: 'start'
        position: 'left'
      dataProvider: stats.data
      graphs: [
        title: 'Session Length'
        valueField: 'length'
        lineThickness: 3
        bullet: 'round'
        bulletSize: 7
      ]
      export:
        enabled: true