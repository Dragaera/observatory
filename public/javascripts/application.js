$(document).ready(function() {
	$('.select2').select2({
		theme: 'bootstrap'
	});

  $('#form-dynamic-add').click(
    function(e) {
      e.preventDefault();
      $('#form-dynamic-container').append(get_html());
    }
  );

  $('#form-dynamic-container').on(
    "click",
    ".form-dynamic-remove",
    function(e) {
      e.preventDefault();
      $(this).parents('.form-dynamic-wrapper').remove();
    }
  );

  $('[data-toggle="tooltip"]').tooltip();
});

function get_html() {
  var $html = $('#form-dynamic-template').clone();

  return $html.html();
}
