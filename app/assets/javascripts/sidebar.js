// on turbolinks load 
$(document).on('turbolinks:load', function() {
  initMenu();

  // init sessionStorage
  function initMenu(){
    if(sessionStorage.getItem('menu_display') === null){
        sessionStorage.setItem('menu_display', true);
    }else if(sessionStorage.getItem('menu_display') === 'false' || sessionStorage.getItem('menu_display') == 'false'){
      if(!$("#wrapper").hasClass("toggled")){
        $("#wrapper").addClass("toggled");
      }
    }
  }

  // manejamos el valor sessionStorage y pliegue/desiplegue del menu
  $("#menu-toggle").click(function(e) {
    e.preventDefault();
    
    $("#wrapper").toggleClass("toggled");

    if(sessionStorage.getItem('menu_display') !== null){
      // sessionStorage es null y no tiene la clase 'toggled'
      const newValue = !(sessionStorage.getItem('menu_display') === 'true' || sessionStorage.getItem('menu_display') == 'true');
      sessionStorage.setItem('menu_display', newValue);
    }else if(sessionStorage.getItem('menu_display') === null){
      // sessionStorage es null y tiene la clase 'toggled'
      sessionStorage.setItem('menu_display', $("#wrapper").hasClass('toggled'));
    }
  });
});