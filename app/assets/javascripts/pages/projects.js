(function () {
	function page_scripts() {
		if (!$("#projects").length) return;

		var $projects = $(".project");

		$projects.each(function (index, el) {
			var $btn = $(el).find(".add-more");
			var $menu = $btn.siblings(".menu");
			var timeout;

			$btn.click(function (e) { e.preventDefault(); });

			$(el).on("mouseenter", ".add-more, .menu", function () {
				clearTimeout(timeout);
				timeout = null;
				$menu.addClass("active");
			});

			$(el).on("mouseleave", ".add-more, .menu", function () {
				timeout = setTimeout(function () {
					$menu.removeClass("active");
				}, 400);
			});
		});
	};

	$(page_scripts);
	$(document).on('page:load', page_scripts);
})();
