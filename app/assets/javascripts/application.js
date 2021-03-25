// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require jquery3
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require chosen-jquery
//= require font_awesome5
//= require popper
//= require moment
//= require moment/es.js
//= require moment-timezone-with-data
//= require tempusdominus-bootstrap-4.js
//= require filterrific/filterrific-jquery
//= require highcharts
//= require chartkick
//= require Chart.bundle
//= require turbolinks
//= require cocoon
//= bootstrap-switch-button
//= require bootstrap
//= require bootstrap-select
//= require_tree .

// Se oculta el flash message
window.setTimeout(function() {
  $(".alert").fadeTo(500, 0).slideUp(500, function(){
      $(this).remove();
  });
}, 10000);

$('[data-toggle="tooltip"]').tooltip({
  'selector': '',
  'container':'body'
});

$.fn.selectpicker.defaults = {
  selectAllText: 'Todos',
  deselectAllText: 'Ninguno'
};

$('#filterrific_filter').on(
  "change",
  ":input",
  function (e) {
    e.stopImmediatePropagation();
    $(this).off("blur");
    Filterrific.submitFilterForm;
  }
);

$(document).on('turbolinks:load', function() {

  $(document).ready(function($) {
    $(".table-row").click(function() {
        window.document.location = $(this).data("href");
    });
  });

  $('#filterrific_filter').on(
    "change",
    ":input",
    function (e) {
    e.stopImmediatePropagation();
    $(this).off("blur");
    Filterrific.submitFilterForm;
    }
  );

  $('.since-date, .to-date, .requested-date, .prescribed-date, .datetimepicker').datepicker({
    closeText: 'Cerrar',
    prevText: '<Ant',
    nextText: 'Sig>',
    currentText: 'Hoy',
    monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
    monthNamesShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
    dayNames: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
    dayNamesShort: ['Dom', 'Lun', 'Mar', 'Mié', 'Juv', 'Vie', 'Sáb'],
    dayNamesMin: ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá'],
    weekHeader: 'Sm',
    dateFormat: 'dd/mm/yy',
    firstDay: 1,
    isRTL: false,
    showMonthAfterYear: false,
    yearSuffix: ''
  });

  $('.quantity_ord_supply_lots').on('cocoon:after-insert', function(e, insertedItem) {
    $('.selectpicker').selectpicker({style: 'btn-sm btn-default'}); // Se inicializa selectpicker luego de agregar form
  });

  $('.selectpicker').selectpicker({
    style: 'btn-light'
  }); // Se inicializa selectpicker

  $('.selectpicker-md').selectpicker({
    style: 'btn btn-light',
  });

  // var today = new moment();
  // $('#requested-date').datetimepicker({
  //   format: 'DD/MM/YYYY',
  //   date: today,
  //   locale: 'es'
  // });

  $('#since-datepicker').datetimepicker({
    format: 'DD/MM/YYYY',
    locale: 'es'
  });

  $(".required").prop('required', true);

  $('[data-toggle="tooltip"]').tooltip({
    'selector': '',
    'container':'body'
  });

  // Se oculta el flash message
  window.setTimeout(function() {
    $(".alert").fadeTo(500, 0).slideUp(500, function(){
      $(this).remove();
    });
  }, 10000);

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

  $('.search-lots').click(function (event) {
    var nested_form = $(this).parents(".nested-fields");
    nested_form.find(".select-change").trigger('change');
    nested_form.find('.search-lots').hide();
  });
});

$(document).on('turbolinks:load', function() {

  $("#internal_order_since_date , #internal_order_to_date, #external_order_since_date, #external_order_to_date, #report_since_date, #report_to_date").datetimepicker({
    format: 'DD/MM/YYYY',
    locale: 'es',
    icons: {
      time: "far fa-clock",
    }
  });

  
  /* new version */
  $('[data-toggle="popover"]').popover();
  
  $('.delete-item').on('click', function(e) {
    const modal = $(e.target).attr('data-target');
    const title = $(e.target).attr('data-title');
    const body = $(e.target).attr('data-body');
    const href = $(e.target).attr('data-href');

    $(modal).find('.modal-title').text(title);
    $(modal).find('.modal-body').text(body);
    $(modal).find('.btn[data-method="delete"]').attr('href', href);
    $(modal).modal('toggle');
    
  });

  // Inicializamos todos los switch buttons
  $('input[type=checkbox][data-toggle="switchbutton"]').each(function( index, element ) {
    element.switchButton();
  });

});

// delete confirm
