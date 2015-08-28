$ ->
  $('.switchboard-item').each ->
    $item = $(@)
    $checkbox = $('.js-switch', $item)

    new Switchery $checkbox[0]

    $checkbox.on 'change', ->
      location.href = $(@).data('url')