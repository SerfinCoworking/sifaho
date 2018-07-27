"use strict";!function(t){"object"==typeof module&&module.exports?module.exports=t:t(Highcharts)}(function(t){!function(y){function v(t,e){var n=b.getElementsByTagName("head")[0],o=b.createElement("script");o.type="text/javascript",o.src=t,o.onload=e,o.onerror=function(){y.error("Error loading script "+t)},n.appendChild(o)}var t=y.merge,w=y.win,x=w.navigator,b=w.document,L=y.each,U=w.URL||w.webkitURL||w,r=/Edge\/|Trident\/|MSIE /.test(x.userAgent),i=/Edge\/\d+/.test(x.userAgent),h=r?150:0;y.CanVGRenderer={},y.dataURLtoBlob=function(t){if(w.atob&&w.ArrayBuffer&&w.Uint8Array&&w.Blob&&U.createObjectURL){for(var e,n=t.match(/data:([^;]*)(;base64)?,([0-9A-Za-z+/]+)/),o=w.atob(n[3]),a=new w.ArrayBuffer(o.length),i=new w.Uint8Array(a),r=0;r<i.length;++r)i[r]=o.charCodeAt(r);return e=new w.Blob([i],{type:n[1]}),U.createObjectURL(e)}},y.downloadURL=function(t,e){var n,o=b.createElement("a");if("string"==typeof t||t instanceof String||!x.msSaveOrOpenBlob){if((i||2e6<t.length)&&!(t=y.dataURLtoBlob(t)))throw"Data URL length limit reached";if(o.download!==undefined)o.href=t,o.download=e,b.body.appendChild(o),o.click(),b.body.removeChild(o);else try{if((n=w.open(t,"chart"))===undefined||null===n)throw"Failed to open window"}catch(a){w.location.href=t}}else x.msSaveOrOpenBlob(t,e)},y.svgToDataUrl=function(t){var e=-1<x.userAgent.indexOf("WebKit")&&x.userAgent.indexOf("Chrome")<0;try{if(!e&&x.userAgent.toLowerCase().indexOf("firefox")<0)return U.createObjectURL(new w.Blob([t],{type:"image/svg+xml;charset-utf-16"}))}catch(n){}return"data:image/svg+xml;charset=UTF-8,"+encodeURIComponent(t)},y.imageToDataUrl=function(a,i,r,l,c,t,s,e,g){var d,f=new w.Image,n=function(){setTimeout(function(){var t,e=b.createElement("canvas"),n=e.getContext&&e.getContext("2d");try{if(n){e.height=f.height*l,e.width=f.width*l,n.drawImage(f,0,0,e.width,e.height);try{t=e.toDataURL(i),c(t,i,r,l)}catch(o){d(a,i,r,l)}}else s(a,i,r,l)}finally{g&&g(a,i,r,l)}},h)},o=function(){e(a,i,r,l),g&&g(a,i,r,l)};d=function(){f=new w.Image,d=t,f.crossOrigin="Anonymous",f.onload=n,f.onerror=o,f.src=a},f.onload=n,f.onerror=o,f.src=a},y.downloadSVGLocal=function(i,t,r,l){function c(t,e){var n=t.width.baseVal.value+2*e,o=t.height.baseVal.value+2*e,a=new w.jsPDF("l","pt",[n,o]);return L(t.querySelectorAll('*[visibility="hidden"]'),function(t){t.parentNode.removeChild(t)}),w.svg2pdf(t,a,{removeInvalid:!0}),a.output("datauristring")}function e(){f.innerHTML=i;var t,e,n=f.getElementsByTagName("text"),o=f.getElementsByTagName("svg")[0].style;L(n,function(e){L(["font-family","font-size"],function(t){!e.style[t]&&o[t]&&(e.style[t]=o[t])}),e.style["font-family"]=e.style["font-family"]&&e.style["font-family"].split(" ").splice(-1),t=e.getElementsByTagName("title"),L(t,function(t){e.removeChild(t)})}),e=c(f.firstChild,0);try{y.downloadURL(e,p),l&&l()}catch(a){r()}}var n,o,s,g=!0,d=t.libURL||y.getOptions().exporting.libURL,f=b.createElement("div"),h=t.type||"image/png",p=(t.filename||"chart")+"."+("image/svg+xml"===h?"svg":h.split("/")[1]),m=t.scale||1;if(d="/"!==d.slice(-1)?d+"/":d,"image/svg+xml"===h)try{x.msSaveOrOpenBlob?((o=new MSBlobBuilder).append(i),n=o.getBlob("image/svg+xml")):n=y.svgToDataUrl(i),y.downloadURL(n,p),l&&l()}catch(u){r()}else"application/pdf"===h?w.jsPDF&&w.svg2pdf?e():(g=!0,v(d+"jspdf.js",function(){v(d+"svg2pdf.js",function(){e()})})):(n=y.svgToDataUrl(i),s=function(){try{U.revokeObjectURL(n)}catch(u){}},y.imageToDataUrl(n,h,{},m,function(t){try{y.downloadURL(t,p),l&&l()}catch(u){r()}},function(){var t=b.createElement("canvas"),e=t.getContext("2d"),n=i.match(/^<svg[^>]*width\s*=\s*\"?(\d+)\"?[^>]*>/)[1]*m,o=i.match(/^<svg[^>]*height\s*=\s*\"?(\d+)\"?[^>]*>/)[1]*m,a=function(){e.drawSvg(i,0,0,n,o);try{y.downloadURL(x.msSaveOrOpenBlob?t.msToBlob():t.toDataURL(h),p),l&&l()}catch(u){r()}finally{s()}};t.width=n,t.height=o,w.canvg?a():(g=!0,v(d+"rgbcolor.js",function(){v(d+"canvg.js",function(){a()})}))},r,r,function(){g&&s()}))},y.Chart.prototype.getSVGForLocalExport=function(t,e,n,o){var a,i,r,l,c,s,g=this,d=0,f=function(t){return g.sanitizeSVG(t,r)},h=function(t,e,n){++d,n.imageElement.setAttributeNS("http://www.w3.org/1999/xlink","href",t),d===a.length&&o(f(i.innerHTML))};y.wrap(y.Chart.prototype,"getChartHTML",function(t){var e=t.apply(this,Array.prototype.slice.call(arguments,1));return r=this.options,i=this.container.cloneNode(!0),e}),g.getSVGForExport(t,e),a=i.getElementsByTagName("image");try{if(!a.length)return void o(f(i.innerHTML));for(c=0,s=a.length;c<s;++c)l=a[c],y.imageToDataUrl(l.getAttributeNS("http://www.w3.org/1999/xlink","href"),"image/png",{imageElement:l},t.scale,h,n,n,n)}catch(p){n()}},y.Chart.prototype.exportChartLocal=function(t,e){var n=this,o=y.merge(n.options.exporting,t),a=function(){if(!1===o.fallbackToExportServer){if(!o.error)throw"Fallback to export server disabled";o.error(o)}else n.exportChart(o)},i=function(t){-1<t.indexOf("<foreignObject")&&"image/svg+xml"!==o.type?a():y.downloadSVGLocal(t,o,a)};r&&("application/pdf"===o.type||n.container.getElementsByTagName("image").length&&"image/svg+xml"!==o.type)||"application/pdf"===o.type&&n.container.getElementsByTagName("image").length?a():n.getSVGForLocalExport(o,e,a,i)},t(!0,y.getOptions().exporting,{libURL:"https://code.highcharts.com/6.0.3/lib/",menuItemDefinitions:{downloadPNG:{textKey:"downloadPNG",onclick:function(){this.exportChartLocal()}},downloadJPEG:{textKey:"downloadJPEG",onclick:function(){this.exportChartLocal({type:"image/jpeg"})}},downloadSVG:{textKey:"downloadSVG",onclick:function(){this.exportChartLocal({type:"image/svg+xml"})}},downloadPDF:{textKey:"downloadPDF",onclick:function(){this.exportChartLocal({type:"application/pdf"})}}}})}(t)});