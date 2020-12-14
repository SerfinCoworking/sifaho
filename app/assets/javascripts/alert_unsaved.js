
let unsaved = false;
 
$(document).on('change', 'form[role="check-modified"]:not([data-remote]) :input', function() {
  return unsaved = true;
});
 
$(document).on('turbolinks:load', function() {
  return unsaved = false;
});
 
$(document).on('submit', 'form[role="check-modified"]', function() {
  unsaved = false;
});
 
 
$(document).on('turbolinks:before-visit', function(event) {
  if(unsaved){
    event.preventDefault();
    modalConfirm(function(confirm){
      if(confirm){
        window.location = event.originalEvent.data.url;
      }
    });
  }
});

// esta funcion abre el modal de confirmacion, al tratar de abandonar una pagina sin haber guardado
function modalConfirm(callback){

  $("#confirm-unsaved").modal('show');

  $("#confirm-unsaved-btn").on("click", function(){
    callback(true);
    $("#confirm-unsaved").modal('hide');
  });
  
  $("#no-confirm-unsaved-btn").on("click", function(){
    callback(false);
    $("#confirm-unsaved").modal('hide');
  });
};