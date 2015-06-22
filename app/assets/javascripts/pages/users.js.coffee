$ ->
  $('.limit-account-link').on 'click', ->
    $link = $(@)
    $form = $('#limit-account-form')

    $form.attr('action', "/users/#{$link.data('id')}")
    $('input.form-control', $form).val $link.data('value')