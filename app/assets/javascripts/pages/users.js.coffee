$ ->
  $('.manage-link').on 'click', ->
    $canvas = $('#manage-modal .modal-content')
    $canvas.html('').css('min-height', '200px').spin()

    $.get $(@).data('url'), (data) ->
      $canvas.spin(false)
      $canvas.html(data)

      $('form.edit_user #user_role').on 'change', ->
        if $(this).val() == 'basic'
          $('form.edit_user .no-basic').hide()
        else
          $('form.edit_user .no-basic').show()

      $('form.edit_user #user_role').trigger 'change'