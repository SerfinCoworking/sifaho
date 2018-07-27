"use strict";!function(e){"object"==typeof module&&module.exports?module.exports=e:e(Highcharts)}(function(e){var t,s,i,n,a,r,o,h,u,d,c,l=(s=(t=e).each,i=t.Series,n=t.addEvent,a=t.fireEvent,r=t.wrap,o={init:function(){i.prototype.init.apply(this,arguments),this.initialised=!1,this.baseSeries=null,this.eventRemovers=[],this.addEvents()},setDerivedData:t.noop,setBaseSeries:function(){var e=this.chart,t=this.options.baseSeries,s=t&&(e.series[t]||e.get(t));this.baseSeries=s||null},addEvents:function(){var e,t=this;e=n(this.chart,"seriesLinked",function(){t.setBaseSeries(),t.baseSeries&&!t.initialised&&(t.setDerivedData(),t.addBaseSeriesEvents(),t.initialised=!0)}),this.eventRemovers.push(e)},addBaseSeriesEvents:function(){var e,t,s=this;e=n(s.baseSeries,"updatedData",function(){s.setDerivedData()}),t=n(s.baseSeries,"destroy",function(){s.baseSeries=null,s.initialised=!1}),s.eventRemovers.push(e,t)},destroy:function(){s(this.eventRemovers,function(e){e()}),i.prototype.destroy.apply(this,arguments)}},r(t.Chart.prototype,"linkSeries",function(e){e.call(this),a(this,"seriesLinked")}),o);u=l,d=(h=e).each,c=h.correctFloat,(0,h.seriesType)("pareto","line",{zIndex:3},(0,h.merge)(u,{setDerivedData:function(){if(1<this.baseSeries.yData.length){var e=this.baseSeries.xData,t=this.baseSeries.yData,s=this.sumPointsPercents(t,e,null,!0);this.setData(this.sumPointsPercents(t,e,s,!1),!1)}},sumPointsPercents:function(e,s,i,n){var a,r=0,o=0,h=[];return d(e,function(e,t){null!==e&&(n?r+=e:(a=e/i*100,h.push([s[t],c(o+a)]),o+=a))}),n?r:h}}))});