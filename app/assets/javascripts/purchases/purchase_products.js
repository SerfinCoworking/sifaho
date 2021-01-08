$(document).on('turbolinks:load', function(e){

  if(!(_PAGE.controller === 'purchases' && (['set_products'].includes(_PAGE.action))) ) return false;
  /* Se agrega el numero de renglon a apartir del siguiente numero del ultimo renglon */
  let lastChildCount = $('#purchase-cocoon-container').find('tr.nested-fields').length;
  $('#purchase-cocoon-container').on('cocoon:before-insert', function(e, insertedItem, originalEvent) {
    lastChildCount++;
    $(insertedItem[0]).find('input.purchase-product-line').first().val(lastChildCount);
  });
  
  /* Inicializamos el evento BEFORE-INSERT de los concoons de seleccion de lote */
  $(".lot-stock-cocoon-container").on('cocoon:before-insert', function(e, added_task) {
    e.stopPropagation();
  });
  /* Inicializamos el evento AFTER-INSERT de los concoons de seleccion de lote */
  $(".lot-stock-cocoon-container").on('cocoon:after-insert', function(e, added_task) {
    e.stopPropagation();
    initLotStockFields();
  });

  /* Boton para visualizar el collapsable */
  $("#purchase-cocoon-container .btn-coll").on('click', function(e){  
    e.stopPropagation();
    const collapsable = $(e.target).closest('tbody').find($(e.target).attr('data-target'));
    $(collapsable).toggleClass("show");
  });
  
  initializerEvents();// inicializamos autocompletar de seleccion de producto
  initLotStockFields();// inicializamos los autocompletar de seleccion de lotes y fecha

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
  
  /* cocoon principal init */  
  $('#purchase-cocoon-container').on('cocoon:after-insert', function(e, added_task) {
    // el template que se inserta tiene mas de un tr, por lo tanto lo transformamos a un array 
    // y luego buscamos el tr correspondiente
    const addedTaskArr = $(added_task).toArray(); 
    const mainRow = addedTaskArr.find((element) => {
      return $(element).hasClass('nested-fields');
    });
    const lotSelectionRow = addedTaskArr.find((element) => {
      return $(element).hasClass('collapsable-row');
    });
    
    const btnLotSelection = $(mainRow).find('.btn-coll').first();
    const collapseContent = $(lotSelectionRow).find(".collapse-custom#collapsable-custom").first();
    
    // debemos actualizar el ID del collapse y el boton que lo despliega
    $(btnLotSelection).attr("data-target", "#collapsable-custom-" + e.timeStamp);
    $(collapseContent).attr("id", "collapsable-custom-" + e.timeStamp);
    // debemos actualizar el ID de la tabla donde se hace el prepend de cada lote y el link con ese ID
    const tBodyLots = $(lotSelectionRow).find("tbody#lot-stock-cocoon-container").first();
    const buttonAddLot = $(lotSelectionRow).find("a.btn-add-lote-association").first();
    $(tBodyLots).attr("id", "lot-stock-cocoon-container-" + e.timeStamp);
    $(buttonAddLot).attr("data-association-insertion-node", "tbody#lot-stock-cocoon-container-" + e.timeStamp);
    initializerEvents(btnLotSelection);
    
    $("#lot-stock-cocoon-container-" + e.timeStamp).on('cocoon:before-insert', function(e, added_task) {
      e.stopPropagation();
    });

    $("#lot-stock-cocoon-container-" + e.timeStamp).on('cocoon:after-insert', function(e, added_task) {
      e.stopPropagation();
      initLotStockFields();
    });
    
  });
  
  // set expiry date calendar format
  function initializerEvents(btnLoteSelection){
    // autocomplete product code input
    $('.purchase-product-code').autocomplete({
      source: $('.purchase-product-code').attr('data-autocomplete-source'),
      minLength: 1,
      autoFocus: true,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró el código de insumo");
        }
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      select: function (event, ui) { 
        onChangeOnSelectAutoCProductCode(event.target, ui.item);
      },
      change: function (event, ui) {      
        onChangeOnSelectAutoCProductCode(event.target, ui.item);
        const tr = $(event.target).closest(".nested-fields");
        tr.find("input.purchase-quantity").focus(); // changes focus to quantity input
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });

    // Función para autocompletar y buscar el insumo
    $('.purchase-product-name').autocomplete({
      source: $('.purchase-product-name').attr('data-autocomplete-source'),
      minLength: 1,
      autoFocus: true,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró el noombre del insumo");
        }
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      select: function (event, ui) { 
        onSelectAutoCProductName(event.target, ui.item);
        const tr = $(event.target).closest(".nested-fields");
        tr.find("input.purchase-quantity").focus(); // changes focus to quantity input
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });
    if(typeof btnLoteSelection !== 'undefined'){
      // Accion desplegar collapseable de seleccion de lotes
      $(btnLoteSelection).on('click', function(e){  
        e.stopPropagation();
        const collapsable = $(e.target).closest('tbody').find($(e.target).attr('data-target'));
        $(collapsable).toggleClass("show");
      });
    }
  }

  /* Funcion que inicializa:
    .-Input selector de fecha
    .-Autocomplete Codigo (lote)
    .-Autocomplete Laboratorio
   */
  function initLotStockFields(){
    // date input change 
    $('input.datetimepicker-input').on('change', function(e){
      setExpiryDate(e.target);
    });
    // aqui se define el formato para el datepicker de la fecha de vencimiento en "solicitar cargar stock"
    $('.purchase_purchase_products_expiry_date_fake .input-group.date').datetimepicker({
      format: 'MM/YY',
      viewMode: 'months',
      locale: 'es',
      useCurrent: false,
    });
    
    // Autocompletar código de lote
    $(".purchase-product-lot-code").on("focus", function(e) {
      const _this = $(e.target);
      console.log("DEBUG");
      jQuery(function() {
        return $('.purchase-product-lot-code').autocomplete({
          source: '/lots/search_by_code?product_code='+_this.closest(".nested-fields").find(".purchase-product-code").val(),
          minLength: 1,
          messages: {
            noResults: function(count) {
              $(".ui-menu-item-wrapper").html("Nuevo lote");
            }
          },
          search: function( event, ui ) {
            $(event.target).parent().siblings('.with-loading').first().addClass('visible');
          },
          select: function (event, ui){
            const tr = $(event.target).closest(".nested-fields");
            tr.find("input.purchase-laboratory-name").val(ui.item.lab_name).trigger('change'); // update product name input
            tr.find("input.purchase-laboratory-id").val(ui.item.lab_id).trigger('change'); // update product name input
            if(ui.item.expiry_date){
              const expiry_date = moment(ui.item.expiry_date);
              tr.find("input.datetimepicker-input").val(expiry_date.format('MM/YY')); // update product name input
              tr.find("input.purchase-expiry-date").val(expiry_date.endOf('month').format("YYYY-MM-DD")); // update product name input
            }
          },
          response: function(event, ui) {
            $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
          }
        });
      });
    });

    // Autcompletar Laboratorio
    $('.purchase-laboratory-name').autocomplete({
      source: $('.purchase-laboratory-name').data('autocomplete-source'),
      autoFocus: true,
      minLength: 2,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró el laboratorio");
        }
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      select:
      function (event, ui) {
        const td = $(event.target).closest("td");
        td.find("input[type='hidden']").val(ui.item.id).trigger('change'); // update product name input
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });
  } //fin initializer

  function setExpiryDate(target){
    const expireDate = moment($(target).val(), "MM/YY");
    const inputHidden = $(target).closest("td").find('input[type="hidden"]');
    $(inputHidden).val(expireDate.endOf('month').format("YYYY-MM-DD")); 
  }  

  function onChangeOnSelectAutoCProductCode(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.purchase-product-name").val(item.name); // update product name input
      tr.find("input.purchase-unity").val(item.unity); // update product unity input      
      tr.find("input.purchase-product-id[type='hidden']").val(item.id); // update product id input      
    }
  }
  
  function onSelectAutoCProductName(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.purchase-product-code").val(item.code); // update product code input
      tr.find("input.purchase-unity").val(item.unity); // update product unity input
      tr.find("input.purchase-product-id[type='hidden']").val(item.id); // update product id input      
    }
  }

});