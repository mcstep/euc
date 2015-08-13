$ ->
  stats = $('#desktops-chart').data('stats')

  if stats
    AmCharts.makeChart 'desktops-chart',
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
        gridAlpha: 0
        position: 'left'
      valueAxes: [
        stackType: 'regular'
        axisAlpha: 0.3
        gridAlpha: 0
      ]
      dataProvider: stats.data
      graphs: stats.kinds.map (k) ->
        type: 'column',
        valueField: k,
        title: k,
        fillAlphas: 1,
        color: '#000000'
      export:
        enabled: true
