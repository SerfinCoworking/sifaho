$(document).on('turbolinks:load', function() { 
  $('.patient_phones').on('cocoon:after-insert', function(e, insertedItem) {
    console.log("agrego")
    $('.selectpicker').selectpicker({style: 'btn-sm btn-default'}); // Se inicializa selectpicker luego de agregar form
  });
  
  $(document).on('click', '#pat-pres tr', function() {
    var link = $(this).data('href');
    console.log("entro")
     $.ajax({
         type: 'GET',
         url: link
     });
  });
});
$(document).on('turbolinks:load', function() { 
  const $pickerInput = $('.date_time_picker input.date_time_picker');
  const initialValue = $pickerInput.val();
  $('.date_time_picker > .input-group.date').datetimepicker({ format: 'DD/MM/YYYY' });
  return $pickerInput.val(initialValue);
});