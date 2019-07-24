function openNav() {
  document.getElementById("mySidebar").style.width = "220px";
  document.getElementById("main").style.marginLeft = "220px";
  document.getElementById("body-col").classList.add('col-md-10');
  document.getElementById("body-col").classList.remove('col-md-12');
  jQuery(function() {
    $("#openbtn").hide(500);
  })
  if ( Highcharts.charts.length > 0 ){
    Highcharts.charts.forEach(function(chart) {
      chart.reflow();
    });
  }
}

function closeNav() {
  document.getElementById("mySidebar").style.width = "0";
  document.getElementById("main").style.marginLeft= "0";
  document.getElementById("body-col").classList.remove('col-md-10');
  document.getElementById("body-col").classList.add('col-md-12');
  setTimeout(function() {
    jQuery(function() {
      $("#openbtn").fadeToggle(500);
    })
  }, 300);
  if ( Highcharts.charts.length > 0 ){
    Highcharts.charts.forEach(function(chart) {
      chart.reflow();
    });
  }
}
