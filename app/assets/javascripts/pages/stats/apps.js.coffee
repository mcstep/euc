$ ->
  $('.apps-chart').each ->
    stats = $(this).data('stats')
    id    = $(this).attr('id')

    if stats

      AmCharts.makeChart id,
        type: 'pie',
        theme: 'light',
        dataProvider: stats.data
        titleField: 'type'
        valueField: 'number'
        depth3D: 15

$ ->
  stats = $('#workspace-apps-chart').data('stats')

  if stats
    AmCharts.makeChart 'workspace-apps-chart',
      type: 'pie',
      theme: 'light',
      dataProvider: stats.data
      titleField: 'type'
      valueField: 'number'
      depth3D: 15