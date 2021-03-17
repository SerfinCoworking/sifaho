$(document).on('turbolinks:load', function(e){

  if(!(['prescriptions'].includes(_PAGE.controller) && (['new', 'edit', 'create', 'update', 'dispense'].includes(_PAGE.action))) ) return false;

  
  // button submit
  $("button[type='submit']").on('click', function(e){
    e.preventDefault();
    $(e.target).attr('disabled', true);
    $(e.target).siblings('button, a').attr('disabled', true);
    $(e.target).find("div.c-msg").css({"display": "none"});
    $(e.target).find('div.d-none').toggleClass('d-none');
    $('input[name="commit"][type="hidden"]').val($(e.target).attr('data-value')).trigger('change');
    $('form#'+$(e.target).attr('form')).submit();
  });

  // Función para autocompletar nombre y apellido del doctor
/*   $('#professional').autocomplete({
    source: $('#professional').data('autocomplete-source'),
    minLength: 2,
    autoFocus:true,
    messages: {
      noResults: function(count) {
        $(".ui-menu-item-wrapper").html("No se encontró al médico");
      }
    },
    search: function( event, ui ) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    select:
    function (event, ui) {
      $("#professional_id").val(ui.item.id);
    },
    response: function(event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    }
  });
   */

  $('#patient-dni').autocomplete({
    source: $('#patient-dni').data('autocomplete-source'),
    autoFocus: true,
    minLength: 7,
    messages: {
      noResults: function() {
        $(".ui-menu-item-wrapper").html("No se encontró el paciente");
      }
    },
    search: function( event, ui ) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    response: function (event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    },
    select:
    function (event, ui) {
      event.preventDefault();
      // $("#patient").tooltip('hide');
      // $("#patient_id").val(ui.item.id);
      $("#patient-dni").val(ui.item.dni);
      $("#patient-lastname").val(ui.item.lastname);
      $("#patient-firstname").val(ui.item.firstname);
      
      if(ui.item.sex != ''){
        // precargamos el sexo del paciente
        $("#patient-sex option").each((index, item) => {
          const sex = new RegExp(ui.item.sex, 'i');
          if($(item).val() && $(item).val().match(sex)){
            $("#patient-sex").val($(item).val());
            $("#patient-sex").selectpicker('render');
          }
        });
      }
      if(ui.item.create){
        $("#new-chronic").fadeOut(300);
        $("#new-outpatient").fadeOut(300);
        $("#patient-submit").attr('disabled', false);
      }else{
        $("#new-chronic").fadeIn(300);
        $("#new-outpatient").fadeIn(300);
        $("#patient-submit").attr('disabled', true);
      }
      
      const url = $('#patient-dni').attr('data-insurance-url');
      getInsurances(url, ui.item.dni);
      
    }
  });

  $('#patient-dni').on('keyup', function(e) {
    if($(e.target).val().length === 0){
      $(".patient-form-input").val("");
      $(".patient-form-selector").val("");
      $(".patient-form-selector").selectpicker('render');

      $("#new-chronic").fadeOut(300);
      $("#new-outpatient").fadeOut(300);
    }
  });
 

  $('#dialog').on('hidden.bs.modal', function () {
    $('#dialog .modal-header').removeClass('bg-warning');
  });
});