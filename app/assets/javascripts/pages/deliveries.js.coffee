$ ->
  $('#delivery_body').each ->
    CodeMirror.fromTextArea this,
      lineNumbers: true,
      mode: "htmlmixed"

  $('#delivery_global').on 'change', ->
    if $(this).is(':checked')
      $('#delivery_profile_id').val('')

  $('#delivery_profile_id').on 'change', ->
    if $(this).val()
      $('#delivery_global').attr('checked', false)