$ ->
  $('#signup-form .no-password').on 'change', ->
    $('#user_desired_password,#user_desired_password_confirmation').attr('disabled', $(this).is(':checked'))

  $('#user_desired_password,#user_desired_password_confirmation').attr('disabled', $('#signup-form .no-password').is(':checked'))

  $('#user_desired_password').on 'blur', ->
    $('#pswd_info').hide()

  $('#user_desired_password').on 'focus', ->
    $('#pswd_info').show()

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

  matcher = new Bloodhound({
    queryTokenizer: Bloodhound.tokenizers.whitespace
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace
    remote:
      url: '/registration/suggest_company?query=%QUERY'
      wildcard: '%QUERY'
  })

  $('#signup-form #user_company_name').typeahead {minLength: 1, highlight: true}, {source: matcher}