$ ->
  # Login
  if $('#login-modal .flash').length > 0
    $('#login-modal').modal('show')

  $(".forgot-password").on 'click', ->
    $('#login-modal').modal('hide')

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