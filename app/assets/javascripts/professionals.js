$(document).on('turbolinks:load', function() {
  $('input[name="professional-status"]').change( function(e) {
    e.stopPropagation();
    $("input#is_active").val($(this).is(":checked"));
  });
});

$("form#new_professional").bind("ajax:success", function(e, data, status, xhr) {
  if (data.success) {
    $('#sign_in').modal('hide');
    $('#sign_in_button').hide();
    return $('#submit_comment').slideToggle(1000, "easeOutBack");
  } else {
    return alert('failure!');
  }
});