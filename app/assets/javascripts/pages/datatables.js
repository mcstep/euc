(function () {
	function page_scripts() {
		if (!$("#datatables").length) return;

		var $table = $("#orders-datatable");

		$table.dataTable({
			sPaginationType: "full_numbers",
			iDisplayLength: 20,
			aLengthMenu: [[20, 50, 100, -1], [20, 50, 100, "All"]],
			bDestroy: true
		});
	};

	$(page_scripts);
	$(document).on('page:load', page_scripts);
})();
