$ ->
  $('#signup-form .no-password').on 'change', ->
    $('#user_desired_password,#user_desired_password_confirmation').attr('disabled', $(this).is(':checked'))

  $('#user_desired_password,#user_desired_password_confirmation').attr('disabled', $('#signup-form .no-password').is(':checked'))

  #
  # Username validation
  #
  $('#user_integrations_username').on 'blur', ->
    $('#usrname_info').hide()

  $('#user_integrations_username').on 'focus', ->
    $('#usrname_info').show()

  $('#user_integrations_username').on 'keyup', ->
    val = $(this).val()
    ctx = $('#usrname_info')

    if val.length < 6 || val.length > 15
      $('.length', ctx).removeClass('valid').addClass 'invalid'
    else
      $('.length', ctx).removeClass('invalid').addClass 'valid'
    if !val.match(/[\\\/\[\]\:\;\|\=\,\+\*\?\<\>\@]+/)
      $('.characters', ctx).removeClass('invalid').addClass 'valid'
    else
      $('.characters', ctx).removeClass('valid').addClass 'invalid'

  #
  # Password validation
  #
  $('#user_desired_password').on 'blur', ->
    $('#pswd_info').hide()

  $('#user_desired_password').on 'focus', ->
    $('#pswd_info').show()

  $('#user_desired_password').on 'keyup', ->
    val = $(this).val()
    ctx = $('#pswd_info')

    if val.length < 8
      $('.length', ctx).removeClass('valid').addClass 'invalid'
    else
      $('.length', ctx).removeClass('invalid').addClass 'valid'
    if val.match(/[A-z]/)
      $('.letter', ctx).removeClass('invalid').addClass 'valid'
    else
      $('.letter').removeClass('valid').addClass 'invalid'
    if val.match(/[A-Z]/)
      $('.capital', ctx).removeClass('invalid').addClass 'valid'
    else
      $('.capital', ctx).removeClass('valid').addClass 'invalid'
    if val.match(/\d/)
      $('.number', ctx).removeClass('invalid').addClass 'valid'
    else
      $('.number', ctx).removeClass('valid').addClass 'invalid'

  #
  # Company typeahead
  #
  matcher = new Bloodhound({
    queryTokenizer: Bloodhound.tokenizers.whitespace
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace
    remote:
      url: '/registration/suggest_company?query=%QUERY'
      wildcard: '%QUERY'
  })

  $('#signup-form #user_company_name').typeahead {minLength: 1, highlight: true}, {source: matcher}