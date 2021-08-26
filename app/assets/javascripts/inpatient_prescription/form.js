$(document).on('turbolinks:load', function(e){
  if(!(['prescriptions/inpatient_prescriptions'].includes(_PAGE.controller) && (['new', 'edit', 'create', 'update'].includes(_PAGE.action))) ) return false;
  // Creamos la fecha actual + 1 dia
  const today = new Date();
  const tomorrow = new Date();
  tomorrow.setDate(today.getDate() + 1);

  $('.datepicker').datepicker({
    format: "dd/mm/yyyy",
    language: "es",
    autoclose: true,
    endDate: tomorrow,
    startDate: today,
  });

  // button submit
  $("button[type='submit']").on('click', function(e){
    e.preventDefault();
    $(e.target).attr('disabled', true);
    $(e.target).siblings('button, a').attr('disabled', true);
    $(e.target).find("div.c-msg").css({"display": "none"});
    $(e.target).find('div.d-none').toggleClass('d-none');
    $('form#'+$(e.target).attr('form')).submit();
  });
  
  $('select.custom-select-pick').on('changed.bs.select', function(e){
    const findPatientUrl = $(e.target).attr("data-find-patient-url");
    const patientId = $(e.target).val();
    $.ajax({
      url: findPatientUrl,
      method: 'GET',
      dataType: "script",
      data: {
        filterrific: {
          search_by_patient_id: patientId
        },
        hide_patient: true
      }
    });
  });
});