$(document).on('turbolinks:load', function(e){
  if(!(['snomed_concepts'].includes(_PAGE.controller) && (['new', 'create'].includes(_PAGE.action))) ) return false;

  let snomed_concepts_list = null;
  // Complete list of snomed concepts
  $( "#search-concept" ).keyup(function() {
    console.log($(this).attr("data-snomed-search-url"));
    const minlength = 3;
    if ($(this).val().length >= minlength){
      $(".with-loading").show();
      snomed_concepts_list = jQuery.ajax({
        type: $(e.target).attr('method'),
        dataType: 'html',
        data: {
          term: $(this).val(),
        },
        url: $(this).attr("data-snomed-search-url"),
        beforeSend : function() {
          if(snomed_concepts_list != null) {
            snomed_concepts_list.abort();
          }
        },
        success: function(data) {
          // Success
          $("#concepts-list");
          $(".with-loading").hide();
          $("#concepts-list").html(data);
         // Button to complete form
          $('.complete-concept').on('click', function(){
            $('#concept-id').val($(this).attr('data-concept-id'));
            $('#term').val($(this).attr('data-term'));
            $('#fsn').val($(this).attr('data-fsn'));
            $('#semantic-tag').val($(this).attr('data-semantic-tag'));
          });
        },
        error:function(e){
          // Error
        }
      });
    }
  });
});
