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
      +                     '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>'
      +                     '<div class="td-dialog"><h1>Are you sure?</h1></div>'
      +                 '</div>'
      +                 '<div class="modal-body">'
      +                     message
      +                 '</div>'
      +                 '<div class="modal-footer">'
      +                     '<button type="button" class="btn btn-default pull-left" data-dismiss="modal">Cancel</button>'
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

  $('#horizonnative').tooltip('toggle')
  $('#horizonnative').tooltip('hide')
  $('[data-toggle="dropdown"]').dropdown();
  $('[data-toggle="tooltip"]').tooltip();
  $('[data-toggle="popover"]').popover();
  $('[data-provide="datepicker"]').datepicker({format: 'MM d, yyyy'});

  $('#super-user-notifcation .close').click(function() {
    $.cookie("super_user_notification_closed", 1);
  });

  $('#menu-toggle').on('click', function () {
    $('#wrapper').toggleClass('toggled');
    return false;
  });

  if (document.URL.indexOf('forgotpassword') > -1) {
    $('#password-reset-modal').modal('show');
  }

  $('.switch01').on('click', function(e) {
     $('.icon01').toggleClass("icon-arrow-down icon-arrow-up");
   });


  $('.sidebar-divider').on('click', function(e) {
    $(this).toggleClass("collapsed expanded");
    e.preventDefault();
  });
})();