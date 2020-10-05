$(document).on('turbolinks:load', function(e){
  if( _PAGE.controller !== 'internal_orders' && (_PAGE.action !== 'new_applicant' || _PAGE.action !== 'edit_applicant') ) return false;
  
});