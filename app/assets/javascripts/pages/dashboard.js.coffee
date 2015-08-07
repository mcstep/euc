$ -> 
  $('#airwatch-eula-modal').one 'shown.bs.modal', ->
    $('.modal-body', @).append '<iframe src="https://docs.google.com/gview?url=http://www.air-watch.com/downloads/legal/20140701_AirWatch_EULA.pdf&amp;embedded=true" width="100%" height="300"><p>Your browser does not support iframes.</p></iframe>'

  $('#dashboard-launcher').children().on 'mouseenter mouseleave', (e) ->
    $e   = $(@)
    open = e.type == 'mouseenter'

    if $e.is('.open') != open
      $e.find('[data-toggle="dropdown"]').dropdown 'toggle'

  $('.prolong-account-link').on 'click', ->
    $link = $(@)
    $form = $('#prolong-account-form')

    $('#directory_prolongation_user_integration_id').val($link.data('id'))
    $('#directory_prolongation_reason').val('')
    $('.invitation-name', $form).val $link.data('name')
    $('.invitation-username', $form).val $link.data('username')

    if $('#directory_prolongation_expiration_date_new').is('[readonly]')
      $('#directory_prolongation_expiration_date_new').val $link.data('date')
    else
      $('#directory_prolongation_expiration_date_new').datepicker('update', $link.data('date')) 