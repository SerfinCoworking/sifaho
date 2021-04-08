$(document).on('turbolinks:load', function() {

//   const outpatientPrescriptionsCountByDay = JSON.parse($("#week").attr("data-outpatient-prescriptions"));
//   const chronicPrescriptionsCountByDay = JSON.parse($("#week").attr("data-chronic-prescriptions"));
//   const chronicPrescriptionsCountByDayName = JSON.parse($("#week").attr("data-chronic-prescriptions-days"));

//   Highcharts.chart('week', {
//     chart: {
//         type: 'line'
//     },
//     title: {
//         text: 'Recetadas en los últimos 14 días'
//     },
//     subtitle: {
//         text: ''
//     },
//     xAxis: {
//         categories: chronicPrescriptionsCountByDayName    
//     },
//     yAxis: {
//         title: {
//             text: 'Cantidad recetadas'
//         }
//     },
//     plotOptions: {
//         line: {
//             dataLabels: {
//                 enabled: true
//             },
//             enableMouseTracking: false
//         }
//     },
//     series: [{
//         name: 'Ambulatorias',
//         data: outpatientPrescriptionsCountByDay
//     }, {
//         name: 'Crónicas',
//         data: chronicPrescriptionsCountByDay
//     }]
//   });
  
//   const outpatientPrescriptionsCountByMonth = JSON.parse($("#year").attr("data-outpatient-prescriptions"));
//   const chronicPrescriptionsCountByMonth = JSON.parse($("#year").attr("data-chronic-prescriptions"));
//   const chronicPrescriptionsCountByMonthName = JSON.parse($("#year").attr("data-chronic-prescriptions-months"));

//   Highcharts.chart('year', {
//     chart: {
//         type: 'line'
//     },
//     title: {
//         text: 'Recetadas en los últimos 12 meses'
//     },
//     subtitle: {
//         text: ''
//     },
//     xAxis: {
//         categories: chronicPrescriptionsCountByMonthName    
//     },
//     yAxis: {
//         title: {
//             text: 'Cantidad recetadas'
//         }
//     },
//     plotOptions: {
//         line: {
//             dataLabels: {
//                 enabled: true
//             },
//             enableMouseTracking: false
//         }
//     },
//     series: [{
//         name: 'Ambulatorias',
//         data: outpatientPrescriptionsCountByMonth
//     }, {
//         name: 'Crónicas',
//         data: chronicPrescriptionsCountByMonth
//     }]
//   });
});