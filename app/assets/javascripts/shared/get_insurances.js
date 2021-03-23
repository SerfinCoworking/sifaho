function getInsurances(insuranceUrl, dni){
  $.ajax({
    url: insuranceUrl + "/" + dni,
    dataType: "script"
  });

  // $.ajax({
  //   url: url + '/' + dni, // Ruta del controlador
  //   type: 'GET',
  //   data: {
  //   },
  //   dataType: "json",
  //   error: function (XMLHttpRequest, errorTextStatus, error) {
  //   },
  //   success: function (data) {
  //     if (!data.length) {
  //       $('#non-os').toggleClass('invisible', false);
  //       $('#pat-os').toggleClass('invisible', true);
  //     } else {
  //       $("#pat-os-body").html("");
  //       for (var i in data) {
  //         var momentDate = moment(data[i].version)
  //         $("#pat-os-body").append(
  //           "<tr>" +
  //           '<td>' + data[i].financiador + '</td>' +
  //           '<td class="pres-col-pro">' + data[i].codigoFinanciador + '</td>' +
  //           '<td>' + momentDate.format("DD/MM/YYYY") + '</td>' +
  //           "</tr>"
  //         );
  //       }
  //       $('#non-os').toggleClass('invisible', true);
  //       $('#pat-os').toggleClass('invisible', false);
  //     } // End if
  //   }// End success
  // });// End ajax
}