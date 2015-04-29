(function () {
	function page_scripts() {
		$('#features-table').on('click', 'button', function (e) {
			var $button = $(this);
			var id = $button.closest('tr').data('id');
			var isActive = $button.hasClass('btn-success');

			$button
				.prop('disabled', true)
				.addClass('saving');

			$.ajax
				({
					type: 'PATCH',
					url: '/features/' + id,
					contentType: 'application/json',
					dataType: 'json',
					data: JSON.stringify({
						feature: {
							active: !isActive,
						},
					}),
				})
				.done(function (data) {
					if (typeof data === 'object') {
						var active = !!data.active;
						$button
							.toggleClass('btn-success', active)
							.toggleClass('btn-danger', !active)
							.attr('aria-pressed', active);
					}
				})
				.always(function () {
					$button
						.prop('disabled', false)
						.removeClass('saving');
				});
		});

		var $featuresFlushButton = $('#features-flush').on('click', function () {
			var previousVal = $featuresFlushButton.text();

			$featuresFlushButton
				.prop('disabled', true)
				.text('Saving…');

			$.ajax
				({
					type: 'POST',
					url: '/features/flush',
					contentType: 'application/json',
					dataType: 'json',
				})
				.always(function () {
					$featuresFlushButton
						.prop('disabled', false)
						.text(previousVal);
				});
		});
	}

	$(page_scripts);
	$(document).on('page:load', page_scripts);
})();