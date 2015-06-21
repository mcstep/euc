(function () {
  $.rails.allowAction = function(element) {
    var message = element.data('confirm');

    if (!message) { return true; }

    var $link = element
     .clone()
     .removeAttr('class data-confirm')
     .addClass('btn btn-danger')
     .html('Continue');

    var $modalHtml = $(
      '<div class="modal fade" tabindex="-1" role="dialog">'
      +     '<div class="modal-dialog">'
      +         '<div class="modal-content">'
      +             '<form method="post" action="#" role="form">'
      +                 '<div class="modal-header">'
      +                     '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>'
      +                     '<h4 class="modal-title">Are you sure?</h4>'
      +                 '</div>'
      +                 '<div class="modal-body">'
      +                     message
      +                 '</div>'
      +                 '<div class="modal-footer">'
      +                     '<button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>'
      +                 '</div>'
      +             '</form>'
      +         '</div>'
      +     '</div>'
      + '</div>'
    );

    $modalHtml.find('.modal-footer').append($link);

    $modalHtml
      .modal()
      .on('hidden.bs.modal', function () {
      $modalHtml.remove();
    });

    return false;
  };

  $('[data-toggle="tooltip"]').tooltip();
  $('[data-toggle="popover"]').popover();
  $('[data-provide="datepicker"]').datepicker({format: 'dd.mm.yyyy'});

  $('#sidebar-toggle').on('click', function () {
    $('#sidebar').toggleClass('show');
  });

  if (document.URL.indexOf('forgotpassword') > -1) {
    $('#password-reset-modal').modal('show');
  }
})();