function getInsurances(insuranceUrl, dni){
  $.ajax({
    url: insuranceUrl + "/" + dni,
    dataType: "script"
  });
}