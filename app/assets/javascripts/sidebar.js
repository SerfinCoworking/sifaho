function openNav() {
  document.getElementById("mySidebar").style.width = "220px";
  document.getElementById("main").style.marginLeft = "220px";
  document.getElementById("body-col").classList.add('col-md-10');
  document.getElementById("body-col").classList.remove('col-md-12');
  jQuery(function() {
    $("#openbtn").hide(500);
  })
  Highcharts.charts[0].reflow();
  Highcharts.charts[1].reflow();
  Highcharts.charts[2].reflow();
  Highcharts.charts[3].reflow();
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
  Highcharts.charts[0].reflow();
  Highcharts.charts[1].reflow();
  Highcharts.charts[2].reflow();
  Highcharts.charts[3].reflow();
}