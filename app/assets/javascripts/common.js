(function () {
	$('[data-toggle="tooltip"]').tooltip();
	$('[data-toggle="popover"]').popover();

	$('#sidebar-toggle').on('click', function () {
		$('#sidebar').toggleClass('show');
	});
})();
