$ ->
  $('#password-reset-modal').each ->
    if (location.pathname == '/passwordreset')
      $(this).modal('show')