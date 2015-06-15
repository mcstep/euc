(function () {
	if (!dateInputSupported) {
		$('#extend-account-modal').one('show.bs.modal', function () {
			$('#expiresAt')
				.attr('readonly', true)
				.datepicker({
					format: 'yyyy-mm-dd',
					startDate: '0',
					todayBtn: 'linked',
					todayHighlight: true,
				});
		});
	}
})();
