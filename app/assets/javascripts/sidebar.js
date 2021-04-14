// on turbolinks load 
$(document).on('turbolinks:load', function() {
  initMenu();
  let weekChart, yearChart;
  // init sessionStorage
  function initMenu(){
    if(sessionStorage.getItem('menu_display') === null){
        sessionStorage.setItem('menu_display', true);
    }else if(sessionStorage.getItem('menu_display') === 'false' || sessionStorage.getItem('menu_display') == 'false'){
      if(!$("#wrapper").hasClass("toggled")){
        $("#wrapper").addClass("toggled");
      }
    }
  }

  if((_PAGE.controller === 'welcome' && (['index'].includes(_PAGE.action)))){
      
      
      
      const outpatientPrescriptionsCountByDay = JSON.parse($("#week").attr("data-outpatient-prescriptions"));
      const chronicPrescriptionsCountByDay = JSON.parse($("#week").attr("data-chronic-prescriptions"));
      const chronicPrescriptionsCountByDayName = JSON.parse($("#week").attr("data-chronic-prescriptions-days"));
      
      weekChart = Highcharts.chart('week', {
          chart: {
              type: 'line',
              height: 300
            },
            title: {
                text: 'Recetadas en los últimos 14 días'
            },
            subtitle: {
                text: ''
            },
            xAxis: {
                categories: chronicPrescriptionsCountByDayName    
            },
            yAxis: {
                title: {
                    text: 'Cantidad recetadas'
                }
            },
            plotOptions: {
                line: {
                    dataLabels: {
                        enabled: true
                    },
                    enableMouseTracking: false
                }
            },
            series: [{
                name: 'Ambulatorias',
                data: outpatientPrescriptionsCountByDay,
                color: "#709fb0"
            }, {
                name: 'Crónicas',
                data: chronicPrescriptionsCountByDay,
                color: "#413c69"
            }]
        });
        
        const outpatientPrescriptionsCountByMonth = JSON.parse($("#year").attr("data-outpatient-prescriptions"));
        const chronicPrescriptionsCountByMonth = JSON.parse($("#year").attr("data-chronic-prescriptions"));
        const chronicPrescriptionsCountByMonthName = JSON.parse($("#year").attr("data-chronic-prescriptions-months"));
        
        yearChart = Highcharts.chart('year', {
            chart: {
                type: 'line',
                height: 300
            },
            title: {
                text: 'Recetadas en los últimos 12 meses'
            },
            subtitle: {
                text: ''
            },
            xAxis: {
                categories: chronicPrescriptionsCountByMonthName    
            },
            yAxis: {
                title: {
                    text: 'Cantidad recetadas'
                }
            },
            plotOptions: {
                line: {
                    dataLabels: {
                        enabled: true
                    },
                    enableMouseTracking: false
                }
            },
            series: [{
                name: 'Ambulatorias',
                data: outpatientPrescriptionsCountByMonth,
                color: "#709fb0"
            }, {
                name: 'Crónicas',
                data: chronicPrescriptionsCountByMonth,
                color: "#413c69"
            }]
        });
        
    }
        // manejamos el valor sessionStorage y pliegue/desiplegue del menu
    $("#menu-toggle").click(function(e) {
        e.preventDefault();
            
        $("#wrapper").toggleClass("toggled");
        
        if(sessionStorage.getItem('menu_display') !== null){
            // sessionStorage es null y no tiene la clase 'toggled'
        const newValue = !(sessionStorage.getItem('menu_display') === 'true' || sessionStorage.getItem('menu_display') == 'true');
        sessionStorage.setItem('menu_display', newValue);
        }else if(sessionStorage.getItem('menu_display') === null){
        // sessionStorage es null y tiene la clase 'toggled'
        sessionStorage.setItem('menu_display', $("#wrapper").hasClass('toggled'));
        }

        if((_PAGE.controller === 'welcome' && (['index'].includes(_PAGE.action)))){
            weekChart.reflow();
            yearChart.reflow();
        }
    });

});