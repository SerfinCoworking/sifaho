$(document).on('turbolinks:load', function() {

  const expiredLotsPercentage = parseFloat($("#status").attr("data-expired-lots").replace(',', '.'));
  const nearExpiredLotsPercentage = parseFloat($("#status").attr("data-near-expiry-lots").replace(',', '.'));
  const goodLotsPercentage = parseFloat($("#status").attr("data-good-lots").replace(',', '.'));
  Highcharts.chart('status', {
    chart: {
        plotBackgroundColor: null,
        plotBorderWidth: null,
        plotShadow: false,
        type: 'pie'
    },
    title: {
        text: ''
    },
    tooltip: {
        pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
    },
    accessibility: {
        point: {
            valueSuffix: '%'
        }
    },
    plotOptions: {
        pie: {
            allowPointSelect: true,
            cursor: 'pointer',
            colors: ["#dc3545", "#ffc107", "#28a745"],
            dataLabels: {
                enabled: true,
                format: '<b>{point.name}</b>: {point.percentage:.1f} %'
            }
        }
    },
    series: [{
      name: 'Stock',
      colorByPoint: true,
      data: [{
          name: 'Vencido',
          y: expiredLotsPercentage
        }, {
          name: 'Por Vencer',
          y: nearExpiredLotsPercentage,
          sliced: true,
          selected: true
        }, {
          name: 'Vigente',
          y: goodLotsPercentage
        }]
    }]
  });
});

