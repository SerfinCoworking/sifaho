$(document).on('turbolinks:load', function() {
  $('#filterrific_with_professional_type_id').chosen({
    allow_single_deselect: true,
    no_results_text: 'No se encontró el resultado',
    width: '150px'
  });

  $('.chosen-select').chosen({
    allow_single_deselect: true,
    no_results_text: 'No se encontró el resultado',
    width: '200px'
  });

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
    console.log("paso!");
    $('#sign_in').modal('hide');
    $('#sign_in_button').hide();
    return $('#submit_comment').slideToggle(1000, "easeOutBack");
  } else {
    console.log("falló");
    return alert('failure!');
  }
});