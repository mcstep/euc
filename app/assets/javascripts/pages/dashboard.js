(function () {
	// this improves page load time by including the PDF only if it's actually shown
	$('#eula-modal').one('shown.bs.modal', function () {
		$('.modal-body', this).append('<iframe src="https://docs.google.com/gview?url=http://www.air-watch.com/downloads/legal/20140701_AirWatch_EULA.pdf&amp;embedded=true" width="100%" height="0"><p>Your browser does not support iframes.</p></iframe>');
	});

	$('#dashboard-launcher').children().on('mouseenter mouseleave', function (e) {
		var $this = $(this);
		var shouldBeOpen = e.type === 'mouseenter';

		if ($this.hasClass('open') !== shouldBeOpen) {
			$this.find('[data-toggle="dropdown"]').dropdown('toggle');
		}
	});
})();
