$(document).on("keyup change",".apply-request-quant", function() {
  var _this = $(this);
  jQuery(function() {
    var nested_form = _this.parents(".nested-fields");
    nested_form.find('.apply-deliver-quant').val(_this.val());
  });
});