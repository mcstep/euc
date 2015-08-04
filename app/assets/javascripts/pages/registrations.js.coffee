$ ->
  $('#signup-form .no-password').on 'change', ->
    if $(this).is(':checked')
      $('#user_desired_password').val('')
    else
      $('#user_desired_password').focus()

  $('#user_desired_password').on 'keyup', ->
    if $(this).val().length > 0
      $('#signup-form .no-password')[0].checked = false

  $('#user_desired_password').on 'blur', ->
    $('#signup-form .no-password')[0].checked = $(this).val().length == 0