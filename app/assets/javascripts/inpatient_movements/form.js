$(document).on('turbolinks:load', function(e){

  if(!(['prescriptions/inpatient_movements'].includes(_PAGE.controller) && (['new', 'edit', 'create', 'update'].includes(_PAGE.action))) ) return false;
  
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

      if(ui.item.dni != '' && typeof ui.item.lastname !== 'undefined' && typeof ui.item.firstname !== 'undefined'){
        $("#patient-dni").val(ui.item.dni);
        $("#patient-lastname").val(ui.item.lastname).attr('readonly', true);
        $("#patient-firstname").val(ui.item.firstname).attr('readonly', true);
        setPatientSex(ui.item.sex);
        if(ui.item.create){
          const patientCreateUrl = $("#patient-dni").attr("data-create-url");
          const status = ui.item.status.charAt(0).toUpperCase() + ui.item.status.slice(1);
          const contacts = [];
          let patient_email = "";
          const address = {
            country_name: "",
            state_name: "",
            city_name: "",
            postal_code: "",
            line: ""
          };
          for(let index = 0; ui.item.data.contacto.length > index; index++){
            if(['celular', 'fijo'].includes(ui.item.data.contacto[index].tipo)){
              contacts.push({
                phone_type: ui.item.data.contacto[index].tipo,
                number: ui.item.data.contacto[index].valor
              });
            }else if(['email'].includes(ui.item.data.contacto[index].tipo)){
              patient_email = ui.item.data.contacto[index].valor;
            }
          };

          // viene direccion
          if(ui.item.data.direccion.length){
            address.postal_code = ui.item.data.direccion[0].codigoPostal;
            address.line = ui.item.data.direccion[0].valor;
            // viene ubicacion
            if(ui.item.data.direccion[0].ubicacion){
              // viene localidad
              if(ui.item.data.direccion[0].ubicacion.localidad){  
                address.city_name = ui.item.data.direccion[0].ubicacion.localidad.nombre;
              }
              // viene provincia
              if(ui.item.data.direccion[0].ubicacion.provincia){
                address.state_name = ui.item.data.direccion[0].ubicacion.provincia.nombre;
              }
              // viene pais
              if(ui.item.data.direccion[0].ubicacion.pais){
                address.state_name = ui.item.data.direccion[0].ubicacion.provincia.nombre;
                address.country_name = ui.item.data.direccion[0].ubicacion.pais.nombre;
              }
            }
          }

          const patient = {
            first_name: ui.item.firstname,
            last_name: ui.item.lastname,
            dni: ui.item.dni,
            email: patient_email,
            birthdate: ui.item.data.fechaNacimiento,
            sex: "",
            marital_status: capitalize(ui.item.data.estadoCivil),
            status: status,
            address: address,
            andes_id: ui.item.data._id,
            patient_phones_attributes: [ ...contacts ],
            photo_andes_id: ui.item.data.fotoId 
          };
          const sex = $("#patient-sex").val();
          patient.sex = sex;
          // ajax create patient
         

          $.ajax({
            url: patientCreateUrl,
            method: 'POST',
            dataType: "script",
            data: {
              patient: patient
            }
          });

        }else{
          $("#patient-status").val(ui.item.status);
        }

        //Mostramos la imagen [andes]
        const image = new Image();
        if(typeof ui.item.avatar_url !== 'undefined'){
          image.src = ui.item.avatar_url ? ui.item.avatar_url : $('input#profile-placeholder-path').val();
        }else{
          image.src = ui.item.avatar ? "data:image/jpg;base64,"+ui.item.avatar.toString() : $('input#profile-placeholder-path').val();
        }

        $(image).addClass("patient-avatar");
        $("#patient-avatar").html(image);
        
        
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
      $('#patient-id').val(ui.item.id);
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
    $("#patient-sex option").each(function(index, item){
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