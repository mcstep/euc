$ ->
  $('#invitation-modal').each ->
    $modal = $(this)
    $form  = $modal.closest('form')
    $crmId = $('#salesforce', $form)
    $days  = $('.days', $form)

    refreshDays = ->
      if $crmId.val()
        $days.html $days.data('max')
      else
        $days.html $days.data('min')

    refreshDays()

    $crmId.on 'keydown', refreshDays

    $form.on 'submit', (e) ->
      unless $form.data('force')
        unless $crmId.val()
          e.preventDefault();
          $modal.modal('show');