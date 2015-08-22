$ ->
  # Prolong
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

  # Change Password
  $('#user_desired_password').on 'blur', ->
    $('.pswd_info').hide()

  $('#user_desired_password').on 'focus', ->
    $('.pswd_info').show()

  $('#user_desired_password').on 'keyup', ->
    val = $(this).val()

    if val.length < 8
      $('#length').removeClass('valid').addClass 'invalid'
    else
      $('#length').removeClass('invalid').addClass 'valid'
    if val.match(/[A-z]/)
      $('#letter').removeClass('invalid').addClass 'valid'
    else
      $('#letter').removeClass('valid').addClass 'invalid'
    if val.match(/[A-Z]/)
      $('#capital').removeClass('invalid').addClass 'valid'
    else
      $('#capital').removeClass('valid').addClass 'invalid'
    if val.match(/\d/)
      $('#number').removeClass('invalid').addClass 'valid'
    else
      $('#number').removeClass('valid').addClass 'invalid'