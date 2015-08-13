$ ->
  stats = $('#apps-chart').data('stats')

  if stats
    AmCharts.makeChart 'apps-chart',
      type: 'pie',
      theme: 'light',
      dataProvider: stats.data
      titleField: 'type'
      valueField: 'number'
      depth3D: 15