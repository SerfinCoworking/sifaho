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

  $('#patient-dni').autocomplete({
    source: $('#patient-dni').data('autocomplete-source'),
    autoFocus: true,
    minLength: 6,
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
      // limpiamos los campos de andes
      $(".andes-input").val("");
      $("#patient-phones").html("");
      $(".andes-input").attr('disabled', true);
      //Mostramos la imagen [local]
      if(ui.item.avatar_url){
        const image = new Image();
        image.src = ui.item.avatar_url;
        $(image).addClass("patient-avatar");
        $("#patient-avatar").html(image);
      }

      if(ui.item.dni != '' && typeof ui.item.lastname !== 'undefined' && typeof ui.item.firstname !== 'undefined'){
        $("#patient-dni").val(ui.item.dni);
        $("#patient-lastname").val(ui.item.lastname).attr('readonly', true);
        $("#patient-firstname").val(ui.item.firstname).attr('readonly', true);
        
        if(ui.item.create && typeof ui.item.status === 'undefined'){
          $(".andes-input").removeAttr('disabled');
          $("#patient-status").val("Validado");
          
          // Datos del paciente rellenados con Andes
          $("#patient-birthdate").val(ui.item.data.fechaNacimiento);
          $("#patient-marital-status").val(capitalize(ui.item.data.estadoCivil));

          for(let index = 0; ui.item.data.contacto.length > index; index++){
            if(['celular', 'fijo'].includes(ui.item.data.contacto[index].tipo)){

              const phoneType = $("<input>");
              $(phoneType).attr('id', 'patient-phone-type-'+index)
              .attr('name', 'patient[patient_phones_attributes]['+index+'[phone_type]')
              .attr('type', 'hidden')
              .val(ui.item.data.contacto[index].tipo);
              
              const phoneNumber = $("<input>");
              $(phoneNumber).attr('id', 'patient-phone-number-'+index)
              .attr('name', 'patient[patient_phones_attributes]['+index+'][number]')
              .attr('type', 'hidden')
              .val(ui.item.data.contacto[index].valor);
              $("#patient-phones").append(phoneType, phoneNumber);
            }else if(['email'].includes(ui.item.data.contacto[index].tipo)){
              $("#patient-email").val(ui.item.data.contacto[index].valor);
            }
          };

          $("#patient-postal-code").val(ui.item.data.direccion[0]?.codigoPostal);
          $("#patient-line").val(ui.item.data.direccion[0]?.valor);
          $("#patient-city-name").val(ui.item.data.direccion[0].ubicacion.localidad?.nombre);
          $("#patient-state-name").val(ui.item.data.direccion[0].ubicacion.provincia?.nombre);
          $("#patient-country-name").val(ui.item.data.direccion[0].ubicacion.pais?.nombre);
          $("#patient-andes-id").val(ui.item.data._id);
          $("#patient-andes-photo").val(ui.item.data.fotoId);
          
          //Mostramos la imagen [andes]
          const image = new Image();
          image.src = "data:image/jpg;base64,"+ui.item.avatar.toString();
          $(image).addClass("patient-avatar");
          $("#patient-avatar").html(image);
          
        }else{
          $("#patient-status").val(ui.item.status);
        }
        setPatientSex(ui.item.sex);      
        $("#container-more-info").addClass("show");
        $("#container-receipts-list").addClass("show");
      }else{
        resetForm();
        $("#container-more-info").removeClass("show");
        $("#container-receipts-list").removeClass("show");
      }
      const url = $('#patient-dni').attr('data-insurance-url');
      getInsurances(url, ui.item.dni);
      setPatientPrescriptions(ui.item.create, ui.item.id);
    }
  });
  
  $('#patient-dni').on('keyup', function(e) {
    if($(e.target).val().length < 6){
      resetForm(true);
      resetPatientPrescriptions();
      $("#patient-submit").attr('disabled', true);
      $("#container-more-info").removeClass("show");
      $("#container-receipts-list").removeClass("show");
      $("#last-receipt-title").removeClass('show');      
    }
  });
  /* =================================================FUNCIONES========================================================================= */
  
  /* Reseteamos el formulario */
  function resetForm(readOnly = false){
    $("#patient-status").val("Temporal");
    $("#patient-lastname").val("").attr('readonly', readOnly);
    $("#patient-firstname").val("").attr('readonly', readOnly);
    $("div#patient-avatar").html('');
    setPatientSex("", readOnly);
    $("#new-receipt-buttons").fadeOut(300).html('');
  }
  
  /* Si el paciente existe en DB, seteamos las prescripciones del paciente */
  function setPatientPrescriptions(isCreate, patientId){
    if(isCreate){
      resetPatientPrescriptions();
      $("#patient-submit").attr('disabled', false);
      $("#new-receipt-buttons").fadeOut(300).html('');
    }else{
      $("#patient-submit").attr('disabled', true);      
      getPrescriptionsTo(patientId);
    }
  }

  /* Reset de prescripciones[tabs] */
  function resetPatientPrescriptions(){
    $("div#chronic-prescriptions").html('');
    $("div#outpatient-prescriptions").html('');
    $("div#last-prescription-info").html('');
    $("div#pat-os-body").html('');
    $("#chronic-tab").find('span.badge-secondary').first().html('0');
    $("#outpatient-tab").find('span.badge-secondary').first().html('0');
  }

});

/* Seteamos el sexo del paciente */
function setPatientSex(sex, readOnly){
  if(typeof sex !== 'undefined' && sex !== ''){
    // precargamos el sexo del paciente
    $("#patient-sex option").each((index, item) => {
      const sexMatch = new RegExp(sex, 'i');
      if($(item).val() && $(item).val().match(sexMatch)){
        $('#patient-sex-fake').val($(item).val()).attr('readonly', true).removeClass('d-none');
        $("#patient-sex").val($(item).val()).addClass('d-none');
        $("#patient-sex").selectpicker('refresh');
      }
    });
  }else if(readOnly){
    $('#patient-sex-fake').val("Otro").removeClass('d-none');
    $(".patient-form-selector").val("Otro").addClass('d-none');
    $(".patient-form-selector").selectpicker('refresh');
  }else{
    $('#patient-sex-fake').val("").addClass('d-none');
    $(".patient-form-selector").val("Otro").removeClass('d-none');
    $(".patient-form-selector").selectpicker('refresh');
  }
}

/* Se obtienen las prescripciones */
function getPrescriptionsTo(patientId){
  const prescriptionsUrl = $("#patient-dni").attr("data-prescriptions-url");
  $.ajax({
    url: prescriptionsUrl + "/" + patientId,
    dataType: "script"
  });
}

function capitalize(s){
  if (typeof s !== 'string') return ''
  return s.charAt(0).toUpperCase() + s.slice(1)
}