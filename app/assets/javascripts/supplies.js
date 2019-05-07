document.addEventListener("turbolinks:load", function() {
  $('#supply_date_received').datetimepicker({format: 'DD/MM/YYYY HH:mm'});
  $('#supply_expiry_date').datetimepicker({format: 'DD/MM/YYYY HH:mm'});

  $('#new-supply-unity').chosen({
      allow_single_deselect: true,
      no_results_text: 'No se encontró la unidad',
      width: '150px'
  });
  $('#new-supply-area').chosen({
      allow_single_deselect: true,
      no_results_text: 'No se encontró el area',
      width: '200px'
  });
  $("[name='expiration-check']").bootstrapSwitch({
    offColor: "primary",
    onColor: "default",
    onText: "No",
    offText: "Si",
    labelText: "Expira?",
  });
  $('input[name="expiration-check"]').on('switchChange.bootstrapSwitch', function(event, state) {
    if(state){
      document.getElementById("needs_expiration").value = false;
    }else{
      document.getElementById("needs_expiration").value = true;
    }
  });
  $("[name='is-active-check']").bootstrapSwitch({
    offColor: "success",
    onColor: "danger",
    offText: "Activo",
    onText: "Inactivo",
    labelText: "Estado",
  });
  $('input[name="is-active-check"]').on('switchChange.bootstrapSwitch', function(event, state) {
    if(state){
      document.getElementById("is_active").value = false;
    }else{
      document.getElementById("is_active").value = true;
    }
  });
  $("[name='alarm-check']").bootstrapSwitch({
    offColor: "success",
    onColor: "default",
    offText: "Activa",
    onText: "Inactiva",
    labelText: "Alarma",
  });
  $('input[name="alarm-check"]').on('switchChange.bootstrapSwitch', function(event, state) {
    if(state){
      document.getElementById("active_alarm").value = false;
    }else{
      document.getElementById("active_alarm").value = true;
    }
  });
});