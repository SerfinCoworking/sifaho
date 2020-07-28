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
//= require bootstrap-select
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
//= require bootstrap-switch
//= require bootstrap
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

  $('.quantity_ord_supply_lots').on('cocoon:after-insert', function(e, insertedItem) {
    $('.selectpicker').selectpicker({style: 'btn-sm btn-default'}); // Se inicializa selectpicker luego de agregar form
  });

  $('.selectpicker').selectpicker({style: 'btn-sm btn-default'}); // Se inicializa selectpicker

  $('.selectpicker-md').selectpicker({style: 'btn-default'});

  var today = new moment();
  $('#requested-date').datetimepicker({
    format: 'DD/MM/YYYY',
    date: today,
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

  // Return confirmation modal
  $('#return-confirm').on('show', function() {
    var $submit = $(this).find('.btn-warning'),
    href = $submit.attr('href');
    $submit.attr('href', href.replace('pony', $(this).data('id')));
  });
  
  $('.return-confirm').click(function(e) {
    e.preventDefault();
    $('#return-confirm').data('id', $(this).data('id')).modal('show');
  });

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

  $('.new-expiry-date')
  .datetimepicker({ 
    format: 'MM/YY',
    viewMode: 'months',
    locale: 'es',
    useCurrent: false
  })
  .on('dp.change',function(e)
  {                               
    var nested_form = $(this).parents(".nested-fields");
    if ( !$(this).val()){
      nested_form.find(".new-expiry-date-hidden").val('');
    }else{
      var end_of_month = new Date(e.date.endOf('month'));
      $(this).data("DateTimePicker").date(end_of_month);
      nested_form.find(".new-expiry-date-hidden").val(end_of_month);
    }
  });
  $('.search-lots').click(function (event) {
    var nested_form = $(this).parents(".nested-fields");
    nested_form.find(".select-change").trigger('change');
    nested_form.find('.search-lots').hide();
  });
});
$(document).on('turbolinks:load', function() {

  $("#internal_order_since_date , #internal_order_to_date, #external_order_since_date, #external_order_to_date").datetimepicker({
    format: 'DD/MM/YYYY',
    locale: 'es',
    icons: {
      time: "far fa-clock",
    }
  });
});