$(document).on('turbolinks:load', function() {


  $('input[name="my-checkbox"]').on('init.bootstrapSwitch', function(event, state) {
    document.getElementById("is_active").value = state;
  });

  $("[name='my-checkbox']").bootstrapSwitch({
    onColor: "danger",
    offColor: "success",
    onText: "Inactivo",
    offText: "Activo",
  });

  $('input[name="my-checkbox"]').on('switchChange.bootstrapSwitch', function(event, state) {
    if(state){
      document.getElementById("is_active").value = false;
    }else{
      document.getElementById("is_active").value = true;
    }
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