/* ==============================================================================
// Scripts for the theme
// ============================================================================== */

(function (window, document, undefined) {
	function page_scripts() {
		// skins switcher
		Skins.initialize();

		// sidebar menus
		Sidebar.initialize();

		// build custom selects
		UI.smart_selects();

		// tooltips
		$('[data-toggle="tooltip"]').tooltip();

		// retina display
		if (window.devicePixelRatio >= 1.2) {
			$('[data-2x]').each(function() {
				if (this.tagName == 'IMG') {
					$(this).attr('src', $(this).attr('data-2x'));
				} else {
					$(this).css({
						'background-image': 'url(' + $(this).attr('data-2x') + ')'
					});
				}
			});
		}

		if (document.URL.indexOf('forgotpassword') > -1) {
			$('#password-reset-modal').modal('show');
		}

		// Focus first input when form modal is shown
		$('#form-validation-modal').on('shown.bs.modal', function(e) {
			$('#form-validation-modal').find('input:text:eq(0)').focus();
		});

		$.validator.addMethod('regex', function(value, element, regexpr) {
			return this.optional(element) || regexpr.test(value);
		}, 'Please enter a valid username');

		// Form validation
		$('#new-invitation-form').validate({
			rules: {
				'invitation[recipient_email]': {
					required: true,
					email: true,
					remote: '/invitations/check_invitation'
				},
				'invitation[recipient_firstname]': {
					required: true
				},
				'invitation[recipient_lastname]': {
					required: true
				},
				'invitation[recipient_company]': {
					required: true
				},
				'invitation[recipient_title]': {
					required: true
				},
				'invitation[potential_seats]': {
					required: true,
					digits: true
				},
				'invitation[recipient_username]': {
					required: false,
					regex: /^[a-z0-9._-]+$/i
				},
				'invitation[airwatch_trial]': {
					required: true
				}
			},
			messages: {
				'invitation[recipient_email]': {
					remote: jQuery.format('This email is already in use')
				}
			},
			highlight: function(element) {
				$(element).closest('.form-group').removeClass('success').addClass('error');
			},
			success: function(element) {
				element.addClass('valid').closest('.form-group').removeClass('error').addClass('success');
			}
		});

		// Form validation
		$('#new_invitation').validate({
			rules: {
				'invitation[recipient_email]': {
					required: true,
					email: true,
					remote: '/invitations/check_invitation'
				},
				'invitation[recipient_firstname]': {
					required: true
				},
				'invitation[recipient_lastname]': {
					required: true
				},
				'invitation[recipient_company]': {
					required: true
				},
				'invitation[recipient_title]': {
					required: true
				},
				'invitation[expires_at]': {
					date: true
				},
				'invitation[potential_seats]': {
					required: true,
					digits: true
				},
				'invitation[recipient_username]': {
					required: false,
					regex: /^[a-z0-9._-]+$/i
				},
				'invitation[airwatch_trial]': {
					required: true
				}
			},
			messages: {
				'invitation[recipient_email]': {
					remote: jQuery.format('This email is already in use')
				}
			},
			highlight: function(element) {
				$(element).closest('.form-group').removeClass('success').addClass('error');
			},
			success: function(element) {
				element.addClass('valid').closest('.form-group').removeClass('error').addClass('success');
			}
		});


		// Form validation
		$('.signup_form').validate({
			rules: {
				'email': {
					required: true,
					email: true
				},
				'firstname': {
					required: true
				},
				'lastname': {
					required: true
				},
				'company': {
					required: true
				},
				'title': {
					required: true
				},
				'username': {
					required: false,
					regex: /^[a-z0-9._-]+$/i
				},
				'airwatch_trial': {
					required: true
				}
			},
			highlight: function(element) {
				$(element).closest('.form-group').removeClass('success').addClass('error');
			},
			success: function(element) {
				element.addClass('valid').closest('.form-group').removeClass('error').addClass('success');
			}
		});

		// Form validation
		$('.signin_form').validate({
			rules: {
				'username': {
					required: true
				},
				'password': {
					required: true
				}
			},
			highlight: function(element) {
				$(element).closest('.form-group').removeClass('success').addClass('error');
			},
			success: function(element) {
				element.addClass('valid').closest('.form-group').removeClass('error').addClass('success');
			}
		});

		// Form validation
		$('#password-reset-form').validate({
			rules: {
				'username': {
					required: true
				},
				'email': {
					required: true,
					email: true
				}
			},
			highlight: function(element) {
				$(element).closest('.form-group').removeClass('success').addClass('error');
			},
			success: function(element) {
				element.addClass('valid').closest('.form-group').removeClass('error').addClass('success');
			}
		});

		// Support form validation
		$('#support-form').validate({
			rules: {
				'subject': {
					required: true
				},
				'notes': {
					required: true
				},
			},
			highlight: function(element) {
				$(element).closest('.form-group').removeClass('success').addClass('error');
			},
			success: function(element) {
				element.addClass('valid').closest('.form-group').removeClass('error').addClass('success');
			}
		});

		// Extend account form validation
		$('#extend-account-form').validate({
			rules: {
				'reason': {
					required: true
				},
				'expiresAt': {
					required: true
				},
			},
			highlight: function(element) {
				$(element).closest('.form-group').removeClass('success').addClass('error');
			},
			success: function(element) {
				element.addClass('valid').closest('.form-group').removeClass('error').addClass('success');
			}
		});

		// Limit potential seats form validation
		$('#limit-account-form').validate({
			rules: {
				'reason': {
					required: true,
					number: true,
					min: 0,
				},
			},
			highlight: function(element) {
				$(element).closest('.form-group').removeClass('success').addClass('error');
			},
			success: function(element) {
				element.addClass('valid').closest('.form-group').removeClass('error').addClass('success');
			}
		});


		// Form validation
		$('#password-change-form').validate({
			rules: {
				'current_password': {
					required: true,
					remote: '/password_change/check_password'
				},
				'new_password': {
					required: true
				},
				'new_password_confirm': {
					required: true,
					equalTo: '#new_password'
				}
			},
			messages: {
				'current_password': {
					remote: jQuery.format('Incorrect password')
				}
			},
			highlight: function(element) {
				$(element).closest('.form-group').removeClass('success').addClass('error');
			},
			success: function(element) {
				element.addClass('valid').closest('.form-group').removeClass('error').addClass('success');
			}
		});



		$('.dropdown-toggle').dropdown();
		$('.popoverHorizon').popover({
			container: 'body'
		});

		$('.popoverInviteUserLink').popover({
			html: true,
			trigger: 'manual',
			container: $(this).attr('id'),
			placement: 'top',
			title: 'Note',
			content: '<p style="color: #222222; font-family: \'Helvetica Neue\', Arial, sans-serif; font-weight: normal; text-align: left; line-height: 19px; font-size: 14px; margin: 5px 0 10px; padding: 0;" align="left"> Before provisioning any accounts, please familiarize yourself with the following troubleshooting information:<br/><ul><li><a href="http://pubs.vmware.com/view-52/index.jsp#com.vmware.view.administration.doc/GUID-6B20BD72-2BC3-41A0-A356-F85258EA5A08.html" target="_blank">Troubleshooting View Components</a></li><li><a href="http://pubs.vmware.com/view-52/topic/com.vmware.view.administration.doc/GUID-D2A0D9E0-696D-4962-837C-2EC203F5F79B.html" target="_blank">Troubleshooting Network Connection Problems</a></li><li><a href="http://pubs.vmware.com/view-52/topic/com.vmware.view.administration.doc/GUID-D6ABDC1E-1208-44AA-9048-4E7B9E995FCA.html" target="_blank">Further Troubleshooting Information</a></li></ul></p>'
		}).on('mouseenter', function() {
			var _this = this;
			$(this).popover('show');
			$(this).siblings('.popover').on('mouseleave', function() {
				$(_this).popover('hide');
			});
		}).on('mouseleave', function() {
			var _this = this;
			setTimeout(function() {
				if (!$('.popover:hover').length) {
					$(_this).popover('hide')
				}
			}, 100);
		});

		$('.popoverPotentialSeats').popover({
			container: 'body',
			trigger: 'focus',
			content: 'Please enter the total number of potential Horizon users. This information will only be used for VMware internal reporting.'
		});

		$('.popoverPotentialSeatsModal').popover({
			container: '.modal-body',
			placement: 'bottom',
			trigger: 'focus',
			content: 'Please enter the total number of potential Horizon users. This information will only be used for VMware internal reporting.'
		});

		$('.popoverExtendAccount').popover({
			container: 'body',
			trigger: 'hover',
			placement: 'right',
			content: 'Extend this user\'s account by a month. (Note: This would be a one-time extension)'
		});

		$('.popoverExpiresAt').popover({
			container: 'body'
		});

		$('.btn-toggle').click(function() {
			$(this).find('.btn-active').toggleClass('btn-success');
			$(this).find('.btn-active').toggleClass('active');
			$(this).find('.btn-inactive').toggleClass('btn-danger');
			$(this).find('.btn-inactive').toggleClass('active');
		});

		// Range Datepicker
		$('.datepicker').datepicker({
			format: 'MM d, yyyy',
			autoclose: true,
			orientation: 'right top',
			startDate: new Date(),
			endDate: '+3y'
		});


		// Guided Tour in app with shepherd.js
		var tour = new Shepherd.Tour({
			defaults: {
				classes: 'shepherd-element shepherd-open shepherd-theme-arrows',
				showCancelLink: true
			}
		});

		tour.addStep('example-step', {
			text: 'This is your user profile',
			attachTo: {
				element: '.user-profile',
				on: 'bottom'
			},
			buttons: [{
				text: 'Exit',
				classes: 'btn btn-default',
				action: tour.cancel
			}, {
				text: 'Next',
				classes: 'btn btn-primary',
				action: tour.next
			}]
		});

		tour.addStep('example-step', {
			text: 'These are links to your horizon environment.',
			attachTo: {
				element: '.horizon-links',
				on: 'bottom'
			},
			buttons: [{
				text: 'Back',
				classes: 'btn btn-default',
				action: tour.back
			}, {
				text: 'Next',
				classes: 'btn btn-primary',
				action: tour.next
			}]
		});

		tour.addStep('example-step', {
			text: 'This shows what your invitation limit is, how many you\'ve used and how many you have remaining',
			attachTo: {
				element: '.account-stats',
				on: 'bottom'
			},
			buttons: [{
				text: 'Back',
				classes: 'btn btn-default',
				action: tour.back
			}, {
				text: 'Next',
				classes: 'btn btn-primary',
				action: tour.next
			}]
		});

		tour.addStep('example-step', {
			text: 'This is how you invite a new user',
			attachTo: {
				element: '.invite-user-link',
				on: 'top'
			},
			buttons: [{
				text: 'Back',
				classes: 'btn btn-default',
				action: tour.back
			}, {
				text: 'Done',
				classes: 'btn btn-success',
				action: tour.next
			}]
		});

		$('.start-tour').click(function (e) {
			e.preventDefault();
			tour.start();
			$('html, body').animate({
				scrollTop: $(document).height()
			}, 'slow');
		});


		$('.progress-bar').progressbar({
			display_text: 'center',
			use_percentage: false,
			amount_format: function (p, t) {
				return p + ' of ' + t;
			},
		});


		/**
		 * Returns the data-* attached to the <tr> within the table of invitations.
		 *
		 * @param $elem This must be an element (jQuery/native) within the <tr>
		 */
		function getInvitationData(elem) {
			elem = $(elem).closest('tr');

			return {
				id       : parseInt(elem.data('id')),
				firstname: elem.data('firstname'),
				lastname : elem.data('lastname'),
				expiresAt: new Date(elem.data('expires-at')),
			};
		}

		$('.extend-account-link').on('click', function() {
			var data = getInvitationData(this);

			data.expiresAt.addMonths(1);

			$('#invitationId').val(data.id);
			$('#invitationUser').val(data.firstname + ' ' + data.lastname);
			$('#expiresAt').datepicker('setDate', data.expiresAt);
		});

		$('.extend-account-link-ro').on('click', function() {
			var data = getInvitationData(this);

			data.expiresAt.addMonths(1);

			$('#invitationId').val(data.id);
			$('#invitationUser').val(data.firstname + ' ' + data.lastname);
			$('#expiresAtRo').val(data.expiresAt.toLocaleDateString());
		});

		/*
		 * The PATCH request will be sent to an URL, created by joining
		 * the original action attribute on the #limit-account-form and
		 * the data-id attribute on the invitations entry.
		 */
		var limitAccountForm = $('#limit-account-form')[0];

		if (limitAccountForm) {
			$('.limit-account-link').on('click', function() {
				var $this = $(this);
				var data = getInvitationData($this);

				$.getJSON('/invitations/' + data.id + '/user', function (data) {
					if (data.role === 'vip') {
						var elements = limitAccountForm.elements;
						elements['id'].value = data.id;
						elements['total_invitations'].value = data.total_invitations;
						$('#limit-account-modal').modal('show');
					}
				});
			});

			$('#limit-account-form').on('submit', function (e) {
				var elements = limitAccountForm.elements;
				var id = elements['id'].value;
				var total_invitations = elements['total_invitations'].value;

				$.ajax({
					type: 'PUT',
					url: '/users/' + id,
					contentType: 'application/json',
					dataType: 'json',
					data: JSON.stringify({
						user: {
							total_invitations: total_invitations,
						},
					}),
					success: function () {
						$('#limit-account-modal').modal('hide');
					},
				});

				return false;
			});
		}


		// Range Datepicker
		$('.datepickerExpiresAt').datepicker({
			format: 'D MM d yyyy',
			autoclose: true,
			orientation: 'right top',
			startDate: new Date(),
			endDate: '+3y'
		});
	};

	$('#eula-modal').modal({
		backdrop: 'static',
		keyboard: true
	});

	$('.start-tour').click();

	$(page_scripts);

	$(document).on('page:change', function() {
		window.prevPageYOffset = window.pageYOffset;
		window.prevPageXOffset = window.pageXOffset;
	});

	$(document).on('page:load', function() {
		page_scripts();

		// force re-render -- having an issue with that on Chrome/OSX
		$('.fix-scroll').hide().show();
		//window.scrollTo(window.prevPageXOffset, window.prevPageYOffset);
	});


	var UI = {
		smart_selects: function() {
			var $selects = $('[data-smart-select]');
			$.each($selects, function(index, el) {
				var $select = $(el);

				// It has been already initialized
				if ($select.parent().hasClass('fake-select-wrap')) {
					$select.siblings('.fake-select').html($select.find('option:selected').text());
					return;
				}

				var $wrapper = $('<div class="fake-select-wrap"/>');
				var $fake_select = $('<div class="fake-select"></div>');
				$select.wrap($wrapper);
				$select.after($fake_select);

				// set selected value as default
				$fake_select.html($select.find('option:selected').text());

				// change handler
				$select.change(function() {
					$fake_select.html($(this).find('option:selected').text());
				});

				$select.focus(function() {
					$fake_select.addClass('focus');
				}).focusout(function() {
					$fake_select.removeClass('focus');
				});
			});
		}
	}

	var Skins = {
		initialize: function() {
			var $toggler = $('.skin-switcher .toggler'),
				$menu = $('.skin-switcher .menu'),
				$sidebar = $('.main-sidebar');

			if (!$toggler.length) {
				return;
			}

			if ($.cookie('current_skin')) {
				$sidebar.attr('id', $.cookie('current_skin'));

				$menu.find('a').removeClass('active');
				$menu.find('a[data-skin=' + $.cookie('current_skin') + ']').addClass('active');
			}

			$toggler.click(function(e) {
				e.stopPropagation();
				$menu.toggleClass('active');
			});

			$('body').click(function() {
				$menu.removeClass('active');
			});

			$menu.click(function(e) {
				e.stopPropagation();
			});

			$menu.find('a').click(function(e) {
				e.preventDefault();
				var skin_id = $(this).data('skin');
				$menu.find('a').removeClass('active');
				$(this).addClass('active');
				$sidebar.attr('id', skin_id);

				$.removeCookie('current_skin', {
					path: '/'
				});
				$.cookie('current_skin', skin_id, {
					path: '/'
				});
			})
		}
	}

	var Sidebar = {
		initialize: function() {
			var $sidebar_menu = $('.main-sidebar');

			// my account dropdown menu
			var $account_menu = $sidebar_menu.find('.current-user .menu');
			$('.current-user .name').click(function(e) {
				e.preventDefault();
				e.stopPropagation();
				$account_menu.toggleClass('active');
			});

			$account_menu.click(function(e) {
				e.stopPropagation()
			});
			$('body').click(function() {
				$account_menu.removeClass('active')
			});


			// sidebar menu dropdown levels
			var $dropdown_triggers = $sidebar_menu.find('[data-toggle~="sidebar"]');

			$dropdown_triggers.click(function (e) {
				// fix sidebar height depending on browser dimensions
				function check_height() {
					var height = $('body').height();
					$('.main-sidebar').css('bottom', 'auto');
					var sidebar_height = $('.main-sidebar').height();

					if (height > sidebar_height) {
						$('.main-sidebar').css('bottom', 0);
					} else {
						$('.main-sidebar').css('bottom', 'auto');
					}
				};

				e.preventDefault();

				if (!utils.isTablet()) {
					// reset other dropdown menus
					if (!$(this).closest('.submenu').length) {
						$dropdown_triggers.not(this).removeClass('toggled').siblings('.submenu').slideUp(300, check_height);
					}

					var $trigger = $(this);
					var $dropdown = $(this).siblings('.submenu');

					$trigger.toggleClass('toggled');

					if ($trigger.hasClass('toggled')) {
						$dropdown.slideDown(300, check_height);
					} else {
						$dropdown.slideUp(300, check_height);
					}
				}
			});


			// setup active dropdown menu option
			var path_name = window.location.pathname;
			// reset all links states
			$sidebar_menu.find('.menu-section a').removeClass('active');

			var $active_link = $sidebar_menu.find('a[href="' + path_name + '"]');
			if ($active_link.length) {
				$active_link.addClass('active');

				// it's a link from a submenu
				if ($active_link.parents('.submenu').length) {
					var $parent = $active_link.closest('.option').find('[data-toggle~="sidebar"]');
					$parent.addClass('active toggled');
					$active_link.parents('.submenu').addClass('active');
				}
			} else {
				$sidebar_menu.find('.menu-section .option > a:eq(0)').addClass('active');
			}


			// mobile sidebar toggler
			var $mobile_toggler = $('#content .sidebar-toggler');
			$mobile_toggler.click(function(e) {
				e.stopPropagation();
				$('body').toggleClass('open-sidebar');
			});

			$('#content').click(function() {
				$('body').removeClass('open-sidebar');
			})
		}
	};

	$.rails.allowAction = function(element) {
		var message = element.data('confirm');

		if (!message) {
			return true;
		}

		var $link = element
			.clone()
			.removeAttr('class data-confirm')
			.addClass('btn btn-danger')
			.html('Continue');

		var $modal_html = $(
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

		$modal_html.find('.modal-footer').append($link);

		$modal_html
			.modal()
			.on('hidden.bs.modal', function () {
				$modal_html.remove();
			});

		return false;
	};

	Number.prototype.formatMoney = function(c, d, t) {
		var n = this;
		var c = isNaN(c = Math.abs(c)) ? 2 : c;
		var d = d == undefined ? '.' : d;
		var t = t == undefined ? ',' : t;
		var s = n < 0 ? '-' : '';
		var i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + '';
		var j = (j = i.length) > 3 ? j % 3 : 0;
		return s + (j ? i.substr(0, j) + t : '') + i.substr(j).replace(/(\d{3})(?=\d)/g, '$1' + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : '');
	};

	/*
	 * as per http://stackoverflow.com/a/12793246
	 */
	Date.prototype.addMonths = function (num) {
		var self = this;
		var currentMonth = self.getMonth();

		self.setMonth(self.getMonth() + num)

		if (self.getMonth() != ((currentMonth + num) % 12)){
			self.setDate(0);
		}
	};

	window.utils = {
		isFirefox: function() {
			return navigator.userAgent.toLowerCase().indexOf('firefox') > -1;
		},
		animation_ends: function() {
			return 'animationend webkitAnimationEnd oAnimationEnd';
		},
		isTablet: function() {
			return $('.main-sidebar').width() < 100;
		},
		get_timestamp: function(less_days) {
			return moment().subtract('days', less_days).toDate().getTime();
		}
	};
})(window, document);