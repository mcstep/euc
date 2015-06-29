$ ->
  $('.manage-link').on 'click', ->
    $canvas = $('#manage-modal .modal-content')
    $canvas.html('').css('min-height', '200px').spin()

    $.get $(@).data('url'), (data) ->
      $canvas.spin(false)
      $canvas.html(data)