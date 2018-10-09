$(document).on('turbolinks:load', function() {
  $(document).on("keyup change",".apply-request-quant", function() {
    var _this = $(this);
    jQuery(function() {
      console.log(_this.val());
      var nested_form = _this.parents(".nested-fields");
      nested_form.find('.apply-deliver-quant').val(_this.val());
    });
  });

  $("#provider-sector").prop('required',true);
});