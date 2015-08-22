$ -> 
  $('#airwatch-eula-modal').one 'shown.bs.modal', ->
    $('.modal-body', @).append '<iframe src="https://docs.google.com/gview?url=http://www.air-watch.com/downloads/legal/20140701_AirWatch_EULA.pdf&amp;embedded=true" width="100%" height="300"><p>Your browser does not support iframes.</p></iframe>'

  $('#dashboard-launcher').children().on 'mouseenter mouseleave', (e) ->
    $e   = $(@)
    open = e.type == 'mouseenter'

    if $e.is('.open') != open
      $e.find('[data-toggle="dropdown"]').dropdown 'toggle'