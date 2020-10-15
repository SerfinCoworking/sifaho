$(document).on('turbolinks:load', function(e){
  if ( 
    (_PAGE.controller !== 'internal_orders' && (_PAGE.action !== 'show')) 
    &&
    (_PAGE.controller !== 'external_orders' && (_PAGE.action !== 'show')) 
    ) return false;
  
  setProgressBar();
  
  function setProgressBar() {

    const ul = $("#progress-bar").siblings("ul").first();
    const statusCount = $(ul).find("li").length;

    const percentPerStatus = 100 / (statusCount - 1);
    const activeLiCount = $(ul).find("li.active").length;
    const anuladoLiCount = $(ul).find("li.anulado").length;

    // anulado
    if(anuladoLiCount){      
      $("#progress-bar").css({"width": "100%"});
      $("#progress-bar").siblings('ul').first().find(".badge").addClass("badge-danger");
      $("#progress-bar").parent().addClass('finish-danger');
    }else{
      $("#progress-bar").css({"width": ((activeLiCount - 1) * percentPerStatus)+ "%"});
      $("#progress-bar").siblings('ul').first().find(".badge").addClass("badge-primary");
      if(statusCount == activeLiCount){
        $("#progress-bar").siblings('ul').first().find(".badge").addClass("badge-success");
        $("#progress-bar").parent().addClass('finish-success');
      }
    }
    
  }
});