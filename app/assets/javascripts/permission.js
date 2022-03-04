$(document).on('turbolinks:load', function() {
  if(!(_PAGE.controller === 'permissions' && (['new', 'edit', 'create', 'update'].includes(_PAGE.action))) ) return false;
  $(".perm-mod-toggle-button").on('change', function(e){
    const parent = $(e.target).closest('.card');
    const permissions = parent.find('.perm-toggle-button');
    permissions.each((index, permission) => {
      $(permission).prop('checked', $(e.target).is(':checked'));
    });
  });
  $(".perm-toggle-button").on('change', function(e){
    $(e.target).siblings("input[type='hidden']").val(!$(e.target).is(':checked'));
  });
});
