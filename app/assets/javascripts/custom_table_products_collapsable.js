$(document).on('turbolinks:load', function() {
  $('.toggle-collapse-row td.org-product').on('click', (e) => {
    e.stopPropagation();

    // quitamos tr activo y colapsamos
    $(e.target).closest('tr').siblings('tr').removeClass('active sub-active');
    $(e.target).closest('table').find('.products-collapse.collapse').collapse('hide');
    
    const target = $(e.target).closest('tr').first().attr('data-target');
    
    $(e.target).closest('tr').first().toggleClass("active");
    $(target).closest('tr').first().toggleClass("sub-active");
    $(target).collapse("toggle");
    
  });

});