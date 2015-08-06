$ ->
  $('#signup-form .no-password').on 'change', ->
    $('#user_desired_password,#user_desired_password_confirmation').attr('disabled', $(this).is(':checked'))

  $('#user_desired_password,#user_desired_password_confirmation').attr('disabled', $('#signup-form .no-password').is(':checked'))
