$(document).on('turbolinks:load', function(e){
  
  if( _PAGE.controller !== 'receipts' && (_PAGE.action !== 'new' || _PAGE.action !== 'edit') ) return false;

  initExpiryDateCalendar();
  $('#provider-sector').selectpicker();
  
  // on change establishment input
  $('#receipt-provider-id').on('change', function(e){
    if(typeof e.target.value === 'undefined' || typeof e.target.value === null || e.target.value.length < 2){
      $('#provider-sector').find('option').remove();
      $('#provider-sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
    }
  });

  // autocomplete establishment input
  $('#receipt-provider-id').autocomplete({
    source: $('#receipt-provider-id').data('autocomplete-source'),
    minLength: 2,
    autoFocus:true,
    messages: {
      noResults: function() {
        $(".ui-menu-item-wrapper").html("No se encontró al médico");
      }
    },
    search: function( event, ui ) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    select:
    function (event, ui) {
      getSectors(ui.item.id);
    },
    response: function(event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    }
  });

  // ajax, brings sector according with the establishment ID
  function getSectors(establishmentId){
    if(typeof establishmentId !== 'undefined'){ 
      console.log(establishmentId, "in ajax");
      $.ajax({
        url: "/sectors/with_establishment_id", // Ruta del controlador
        method: "GET",
        dataType: "JSON",
        data: { term: establishmentId}
      })
      .done(function( data ) {
        if(data.length){
          $('#provider-sector').removeAttr("disabled");
          $('#provider-sector').find('option').remove();
          $.each(data, function(index, element){
            $('#provider-sector').append('<option value="'+element.id+'">'+ element.label +'</option>');
          });
          $('#provider-sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
        }else{
          console.log("no se encontraron sectores");
        }
      });
    }else{
      $('#provider-sector').find('option').remove();
      $('#provider-sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
    }
  }

  // cocoon init
  $('#cocoon-container').on('cocoon:after-insert', function(e) {
    initExpiryDateCalendar();
  });
  
  // set expiry date calendar format
  function initExpiryDateCalendar(){
    // date input change 
    $('input.datetimepicker-input').on('change', function(e){
      setExpiryDate(e.target);    
    });
    // aqui se define el formato para el datepicker de la fecha de vencimiento en "solicitar cargar stock"
    $('.receipt_receipt_products_expiry_date_fake .input-group.date').datetimepicker({
      format: 'MM/YY',
      viewMode: 'months',
      locale: 'es',
      useCurrent: false,
    });
    
    $('.receipt_receipt_products_expiry_date_fake .input-group.date').on('change.datetimepicker', function(e){
      const target = $(e.target).find('input.datetimepicker-input').first();
      setExpiryDate(target);
    });
  }

  function setExpiryDate(target){
    const expireDate = moment($(target).val(), "MM/YY");
    const inputHidden = $(target).closest("td").find('.hidden.receipt_receipt_products_expiry_date input[type="hidden"]');
    $(inputHidden).val(expireDate.startOf('month').format("YYYY-MM-DD")); 
  }
});