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
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require chosen-jquery
//= require filterrific/filterrific-jquery
//= require highcharts
//= require chartkick
//= require turbolinks
//= require cocoon
//= require_tree .
//= require moment
//= require bootstrap-datetimepicker
//= require bootstrap-sprockets
//= require bootstrap

// Se oculta el flash message
window.setTimeout(function() {
    $(".alert").fadeTo(500, 0).slideUp(500, function(){
        $(this).remove();
    });
}, 2000);

$(document).on('turbolinks:load', function() {
  $('[data-toggle="tooltip"]').tooltip({delay: { "show": 700, "hide": 100 }});

  $('#datetimepicker').datetimepicker({format: 'DD/MM/YYYY HH:mm'});

  var sidebar = document.getElementById('custom-sidebar');
  var page_header = document.getElementById('page-header');
  // Se cambia el color de la sombra del menú lateral
  if( $(".active").is("#pedidos-li") ) {
    sidebar.style.boxShadow = "8px 0 3px 5px #59457c";
    page_header.style.background = "#59457c";
    page_header.style.borderColor = "#59457c";
  }else if ( $(".active").is("#stock-li") ) {
    sidebar.style.boxShadow = "8px 0 3px 5px #10675f";
    page_header.style.background = "#10675f";
    page_header.style.borderColor = "#10675f";
  }else if ( $(".active").is("#usuarios-li") ){
    sidebar.style.boxShadow = "8px 0 3px 5px #89726a";
    page_header.style.background = "#89726a";
    page_header.style.borderColor = "#89726a";
  }else {
    sidebar.style.boxShadow = "8px 0 3px 5px #7c9ed4";
    page_header.style.background = "#7c9ed4";
    page_header.style.borderColor = "#7c9ed4";
  }

  $("#pedidos").on("hide.bs.collapse", function(){
    $("#pedidos-label").html('<span class="glyphicon glyphicon-chevron-down"></span> <strong>Pedidos</strong>');
  });
  $("#pedidos").on("show.bs.collapse", function(){
    $("#pedidos-label").html('<span class="glyphicon glyphicon-list-alt"></span> <strong>Pedidos</strong>');
  });

  $("#stock").on("hide.bs.collapse", function(){
    $("#stock-label").html('<span class="glyphicon glyphicon-chevron-down"></span> <strong>Stock</strong>');
  });
  $("#stock").on("show.bs.collapse", function(){
    $("#stock-label").html('<span class="glyphicon glyphicon-barcode"></span> <strong>Stock</strong>');
  });

  $("#usuarios").on("hide.bs.collapse", function(){
    $("#usuarios-label").html('<span class="glyphicon glyphicon-chevron-down"></span> <strong>Usuarios</strong>');
  });
  $("#usuarios").on("show.bs.collapse", function(){
    $("#usuarios-label").html('<span class="glyphicon glyphicon-user"></span> <strong>Usuarios</strong>');
  });

});
