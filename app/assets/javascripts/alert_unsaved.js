var msg, unsaved;
 
msg = "Hay cambios sin guardar. Deseas salir igualmente?";
 
unsaved = false;
 
$(document).on('change', 'form[role="check-modified"]:not([data-remote]) :input', function() {
  return unsaved = true;
});
 
$(document).on('turbolinks:load', function() {
  return unsaved = false;
});
 
$(document).on('submit', 'form[role="check-modified"]', function() {
  unsaved = false;
});
 
$(window).bind('beforeunload', function() {
  if (unsaved) {
    return msg;
  }
});
 
$(document).on('turbolinks:before-visit', function(event) {
  if (unsaved && !confirm(msg)) {
    return event.preventDefault();
  }
});