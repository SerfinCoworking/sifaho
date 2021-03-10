$(document).on('turbolinks:load', function(e){

  if(!(_PAGE.controller === 'purchases' && (['new', 'edit', 'create', 'update'].includes(_PAGE.action))) ) return false;
 
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

  $('#provider-sector').selectpicker();
  
  // on change establishment input
  $('#purchase-provider-id').on('change', function(e){
    if(typeof e.target.value === 'undefined' || typeof e.target.value === null || e.target.value.length < 2){
      $('#provider-sector').find('option').remove();
      $('#provider-sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
    }
  });

  // autocomplete establishment input
  $('#purchase-provider-id').autocomplete({
    source: $('#purchase-provider-id').data('autocomplete-source'),
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
      $.ajax({
        url: "/sectores/with_establishment_id", // Ruta del controlador
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
        }
      });
    }else{
      $('#provider-sector').find('option').remove();
      $('#provider-sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
    }
  }  
});