(function () {
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


	/*
	 * TODO:
	 * Currently styling issues arise if <input type="date"> are used
	 * (as the native alternative for the bootstrap-datepicker).
	 * The simplest issue is that the date format is the local one and not en-US anymore.
	 *
	 * => Investigate those style issues and fix them.
	 */
	window.dateInputSupported = false;

	/*window.dateInputSupported = (function () {
		var node = document.createElement('input');
		var invalidVal = 'foo';

		node.setAttribute('type','date');
		node.setAttribute('value', invalidVal);

		// A browser supporting date inputs won't let invalidVal get set as the value.
		return node.value !== invalidVal;
	}());*/



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



	$('[data-toggle="tooltip"]').tooltip();
	$('[data-toggle="popover"]').popover();

	$('#sidebar-toggle').on('click', function () {
		$('#sidebar').toggleClass('show');
	});



	if (document.URL.indexOf('forgotpassword') > -1) {
		$('#password-reset-modal').modal('show');
	}



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

	function dateToISOStringWithoutTime(date) {
		return date.toISOString().substring(0, 10);
	}

	function dateToLocalString(date) {
		return date.toLocaleDateString('en-US', {
			weekday: 'short',
			year   : 'numeric',
			month  : 'long',
			day    : 'numeric',
		});
	}

	$('.extend-account-link').on('click', function() {
		var data = getInvitationData(this);

		data.expiresAt.addMonths(1);

		$('#invitationId').val(data.id);
		$('#invitationUser').val(data.firstname + ' ' + data.lastname);
		$('#expiresAt')
			.attr('min', dateToISOStringWithoutTime(new Date))
			.val(dateToLocalString(data.expiresAt));
	});

	$('.extend-account-link-ro').on('click', function() {
		var data = getInvitationData(this);

		data.expiresAt.addMonths(1);

		$('#invitationId').val(data.id);
		$('#invitationUser').val(data.firstname + ' ' + data.lastname);
		$('#expiresAtRo')
			.attr('min', dateToISOStringWithoutTime(new Date))
			.val(dateToLocalString(data.expiresAt));
	});

	if (!dateInputSupported) {
		$('#extend-account-modal').one('show.bs.modal', function () {
			$('#expiresAt')
				.attr('readonly', true)
				.datepicker({
					format: 'D, MM d, yyyy',
					startDate: '0',
					todayBtn: 'linked',
					todayHighlight: true,
				});
		});
	} else {
		$('#expiresAt')
			.attr('type', 'date')
	}

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
})();
