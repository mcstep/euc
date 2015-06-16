(function () {
	$('#signup-form').on('click', 'input', function () {
		if (this.setSelectionRange) {
			this.setSelectionRange(0, this.value.length);
		}
	});
})();
