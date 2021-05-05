$(document).on('turbolinks:load', function(e){

  if(!(['inpatient_prescriptions'].includes(_PAGE.controller) && (['delivery'].includes(_PAGE.action))) ) return false;
  
  $('button.select-lot-btn').on('click', function(e) {
    const urlFindLots = $(e.target).attr("data-select-lot-url");
    const orderName = $(e.target).attr("data-order-name");
    const orderId = $(e.target).attr("data-order-id");
    const orderProductId = $(e.target).attr("data-order-product-id");
    $.ajax({
      url: urlFindLots,
      method: 'GET',
      dataType: "script",
      data: {
        order_type: orderName,
        order_id: orderId,
        order_product_id: orderProductId
    }});
  });
});