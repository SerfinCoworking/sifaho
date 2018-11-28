$(document).on('turbolinks:load', function() {
  $.fn.bootstrapSwitch.defaults.onColor = 'success';
  $.fn.bootstrapSwitch.defaults.offColor = 'danger';

  $('.datetimepicker').datetimepicker({format: 'DD/MM/YYYY', locale: 'es'});

  $('.selectpicker').selectpicker();

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
  }else if ( $(".active").is("#efectores-li") ){
    sidebar.style.boxShadow = "8px 0 3px 5px #89726a";
    page_header.style.background = "#89726a";
    page_header.style.borderColor = "#89726a";
  }else if ( $(".active").is("#notificaciones-li") ){
    sidebar.style.boxShadow = "8px 0 3px 5px #d36262";
    page_header.style.background = "#d36262";
    page_header.style.borderColor = "#d36262";
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

  $("#efectores").on("hide.bs.collapse", function(){
    $("#efectores-label").html('<span class="glyphicon glyphicon-chevron-down"></span> <strong>Efectores</strong>');
  });
  $("#efectores").on("show.bs.collapse", function(){
    $("#efectores-label").html('<span class="glyphicon glyphicon-user"></span> <strong>Efectores</strong>');
  });
});
