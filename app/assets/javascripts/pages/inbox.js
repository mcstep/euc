(function () {
	function page_scripts() {
		if (!$("body#sidebar").length) return;

		$("html, body").css('height', '100%');
		$(".main-sidebar").wrapInner("<div class='scroll-wrapper'></div>");
	};

	$(page_scripts);
	$(document).on('page:load', page_scripts);
})();
