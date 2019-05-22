$(document).on('turbolinks:load', function() { 
  $('#patient_birthdate').datetimepicker({ format: 'DD/MM/YYYY' });
  $('#patient_type').chosen({
      allow_single_deselect: true,
      no_results_text: 'No se encontró el resultado',
      width: '150px'});
  $("[name='sex-check']").bootstrapSwitch({
    offColor: "default",
    onColor: "default",
    labelWidth: 5,
    labelText: "Sexo",
    indeterminate: true,
    onText: "Hombre",
    offText: "Mujer"
  });

  $('input[name="sex-check"]').on('switchChange.bootstrapSwitch', function(event, state) {
    if(state){
      document.getElementById("sex").value = 3;
    }else{
      document.getElementById("sex").value = 2;
    }
  });

  $("[name='chronic-check']").bootstrapSwitch({
    offColor: "default",
    onColor: "primary",
    onText: "Si",
    offText: "No",
    labelText: "Crónico?",
  });

  $('input[name="chronic-check"]').on('switchChange.bootstrapSwitch', function(event, state) {
    document.getElementById("is_chronic").value = state;
  });

  $("[name='urban-check']").bootstrapSwitch({
    offColor: "default",
    onColor: "primary",
    onText: "No",
    offText: "Si",
    labelText: "Urbano?"
  });
  
  $('input[name="chronic-check"]').on('switchChange.bootstrapSwitch', function(event, state) {
    if(state){
      document.getElementById("is_urban").value = false;
    }else{
      document.getElementById("is_urban").value = true;
    }
  });
});