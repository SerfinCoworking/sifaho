"use strict";!function(t){"object"==typeof module&&module.exports?module.exports=t:t(Highcharts)}(function(t){!function(f){var t=f.defaultOptions,y=f.doc,e=f.Chart,b=f.addEvent,s=f.removeEvent,p=f.fireEvent,v=f.createElement,u=f.discardElement,w=f.css,g=f.merge,m=f.pick,S=f.each,i=f.objectEach,E=f.extend,n=f.isTouchDevice,d=f.win,o=d.navigator.userAgent,r=(f.SVGRenderer,f.Renderer.prototype.symbols);/Edge\/|Trident\/|MSIE /.test(o),/firefox/i.test(o);E(t.lang,{printChart:"Print chart",downloadPNG:"Download PNG image",downloadJPEG:"Download JPEG image",downloadPDF:"Download PDF document",downloadSVG:"Download SVG vector image",contextButtonTitle:"Chart context menu"}),t.navigation={buttonOptions:{theme:{},symbolSize:14,symbolX:12.5,symbolY:10.5,align:"right",buttonSpacing:3,height:22,verticalAlign:"top",width:24}},g(!0,t.navigation,{menuStyle:{border:"1px solid #999999",background:"#ffffff",padding:"5px 0"},menuItemStyle:{padding:"0.5em 1em",background:"none",color:"#333333",fontSize:n?"14px":"11px",transition:"background 250ms, color 250ms"},menuItemHoverStyle:{background:"#335cad",color:"#ffffff"},buttonOptions:{symbolFill:"#666666",symbolStroke:"#666666",symbolStrokeWidth:3,theme:{fill:"#ffffff",stroke:"none",padding:5}}}),t.exporting={type:"image/png",url:"https://export.highcharts.com/",printMaxWidth:780,scale:2,buttons:{contextButton:{className:"highcharts-contextbutton",menuClassName:"highcharts-contextmenu",symbol:"menu",_titleKey:"contextButtonTitle",menuItems:["printChart","separator","downloadPNG","downloadJPEG","downloadPDF","downloadSVG"]}},menuItemDefinitions:{printChart:{textKey:"printChart",onclick:function(){this.print()}},separator:{separator:!0},downloadPNG:{textKey:"downloadPNG",onclick:function(){this.exportChart()}},downloadJPEG:{textKey:"downloadJPEG",onclick:function(){this.exportChart({type:"image/jpeg"})}},downloadPDF:{textKey:"downloadPDF",onclick:function(){this.exportChart({type:"application/pdf"})}},downloadSVG:{textKey:"downloadSVG",onclick:function(){this.exportChart({type:"image/svg+xml"})}}}},f.post=function(t,e,n){var o=v("form",g({method:"post",action:t,enctype:"multipart/form-data"},n),{display:"none"},y.body);i(e,function(t,e){v("input",{type:"hidden",name:e,value:t},null,o)}),o.submit(),u(o)},E(e.prototype,{sanitizeSVG:function(t,e){if(e&&e.exporting&&e.exporting.allowHTML){var n=t.match(/<\/svg>(.*?$)/);n&&n[1]&&(n='<foreignObject x="0" y="0" width="'+e.chart.width+'" height="'+e.chart.height+'"><body xmlns="http://www.w3.org/1999/xhtml">'+n[1]+"</body></foreignObject>",t=t.replace("</svg>",n+"</svg>"))}return t=t.replace(/zIndex="[^"]+"/g,"").replace(/isShadow="[^"]+"/g,"").replace(/symbolName="[^"]+"/g,"").replace(/jQuery[0-9]+="[^"]+"/g,"").replace(/url\(("|&quot;)(\S+)("|&quot;)\)/g,"url($2)").replace(/url\([^#]+#/g,"url(#").replace(/<svg /,'<svg xmlns:xlink="http://www.w3.org/1999/xlink" ').replace(/ (NS[0-9]+\:)?href=/g," xlink:href=").replace(/\n/," ").replace(/<\/svg>.*?$/,"</svg>").replace(/(fill|stroke)="rgba\(([ 0-9]+,[ 0-9]+,[ 0-9]+),([ 0-9\.]+)\)"/g,'$1="rgb($2)" $1-opacity="$3"').replace(/&nbsp;/g,"\xa0").replace(/&shy;/g,"\xad"),this.ieSanitizeSVG&&(t=this.ieSanitizeSVG(t)),t},getChartHTML:function(){return this.container.innerHTML},getSVG:function(n){var r,t,e,o,i,s,a,l,p=this,d=g(p.options,n);return t=v("div",null,{position:"absolute",top:"-9999em",width:p.chartWidth+"px",height:p.chartHeight+"px"},y.body),a=p.renderTo.style.width,l=p.renderTo.style.height,i=d.exporting.sourceWidth||d.chart.width||/px$/.test(a)&&parseInt(a,10)||600,s=d.exporting.sourceHeight||d.chart.height||/px$/.test(l)&&parseInt(l,10)||400,E(d.chart,{animation:!1,renderTo:t,forExport:!0,renderer:"SVGRenderer",width:i,height:s}),d.exporting.enabled=!1,delete d.data,d.series=[],S(p.series,function(t){(o=g(t.userOptions,{animation:!1,enableMouseTracking:!1,showCheckbox:!1,visible:t.visible})).isInternal||d.series.push(o)}),S(p.axes,function(t){t.userOptions.internalKey||(t.userOptions.internalKey=f.uniqueKey())}),r=new f.Chart(d,p.callback),n&&S(["xAxis","yAxis","series"],function(t){var e={};n[t]&&(e[t]=n[t],r.update(e))}),S(p.axes,function(e){var t=f.find(r.axes,function(t){return t.options.internalKey===e.userOptions.internalKey}),n=e.getExtremes(),o=n.userMin,i=n.userMax;!t||o===undefined&&i===undefined||t.setExtremes(o,i,!0,!1)}),e=r.getChartHTML(),e=p.sanitizeSVG(e,d),d=null,r.destroy(),u(t),e},getSVGForExport:function(t,e){var n=this.options.exporting;return this.getSVG(g({chart:{borderRadius:0}},n.chartOptions,e,{exporting:{sourceWidth:t&&t.sourceWidth||n.sourceWidth,sourceHeight:t&&t.sourceHeight||n.sourceHeight}}))},exportChart:function(t,e){var n=this.getSVGForExport(t,e);t=g(this.options.exporting,t),f.post(t.url,{filename:t.filename||"chart",type:t.type,width:t.width||0,scale:t.scale,svg:n},t.formAttributes)},print:function(){var t,e,n=this,o=n.container,i=[],r=o.parentNode,s=y.body,a=s.childNodes,l=n.options.exporting.printMaxWidth;n.isPrinting||(n.isPrinting=!0,n.pointer.reset(null,0),p(n,"beforePrint"),(e=l&&n.chartWidth>l)&&(t=[n.options.chart.width,undefined,!1],n.setSize(l,undefined,!1)),S(a,function(t,e){1===t.nodeType&&(i[e]=t.style.display,t.style.display="none")}),s.appendChild(o),d.focus(),d.print(),setTimeout(function(){r.appendChild(o),S(a,function(t,e){1===t.nodeType&&(t.style.display=i[e])}),n.isPrinting=!1,e&&n.setSize.apply(n,t),p(n,"afterPrint")},1e3))},contextMenu:function(e,t,n,o,i,r,s){var a,l,p,d=this,u=d.options.navigation,c=d.chartWidth,h=d.chartHeight,g="cache-"+e,m=d[g],x=Math.max(i,r);m||(d[g]=m=v("div",{className:e},{position:"absolute",zIndex:1e3,padding:x+"px"},d.container),a=v("div",{className:"highcharts-menu"},null,m),w(a,E({MozBoxShadow:"3px 3px 10px #888",WebkitBoxShadow:"3px 3px 10px #888",boxShadow:"3px 3px 10px #888"},u.menuStyle)),l=function(){w(m,{display:"none"}),s&&s.setState(0),d.openMenu=!1},d.exportEvents.push(b(m,"mouseleave",function(){m.hideTimer=setTimeout(l,500)}),b(m,"mouseenter",function(){clearTimeout(m.hideTimer)}),b(y,"mouseup",function(t){d.pointer.inClass(t.target,e)||l()})),S(t,function(e){var t;("string"==typeof e&&(e=d.options.exporting.menuItemDefinitions[e]),f.isObject(e,!0))&&(e.separator?t=v("hr",null,null,a):((t=v("div",{className:"highcharts-menu-item",onclick:function(t){t&&t.stopPropagation(),l(),e.onclick&&e.onclick.apply(d,arguments)},innerHTML:e.text||d.options.lang[e.textKey]},null,a)).onmouseover=function(){w(this,u.menuItemHoverStyle)},t.onmouseout=function(){w(this,u.menuItemStyle)},w(t,E({cursor:"pointer"},u.menuItemStyle))),d.exportDivElements.push(t))}),d.exportDivElements.push(a,m),d.exportMenuWidth=m.offsetWidth,d.exportMenuHeight=m.offsetHeight),p={display:"block"},n+d.exportMenuWidth>c?p.right=c-n-i-x+"px":p.left=n-x+"px",o+r+d.exportMenuHeight>h&&"top"!==s.alignOptions.verticalAlign?p.bottom=h-o-x+"px":p.top=o+r-x+"px",w(m,p),d.openMenu=!0},addButton:function(t){var e,n,o=this,i=o.renderer,r=g(o.options.navigation.buttonOptions,t),s=r.onclick,a=r.menuItems,l=r.symbolSize||12;if(o.btnCount||(o.btnCount=0),o.exportDivElements||(o.exportDivElements=[],o.exportSVGElements=[]),!1!==r.enabled){var p,d=r.theme,u=d.states,c=u&&u.hover,h=u&&u.select;delete d.states,s?p=function(t){t.stopPropagation(),s.call(o,t)}:a&&(p=function(){o.contextMenu(n.menuClassName,a,n.translateX,n.translateY,n.width,n.height,n),n.setState(2)}),r.text&&r.symbol?d.paddingLeft=m(d.paddingLeft,25):r.text||E(d,{width:r.width,height:r.height,padding:0}),(n=i.button(r.text,0,0,p,d,c,h).addClass(t.className).attr({"stroke-linecap":"round",title:o.options.lang[r._titleKey],zIndex:3})).menuClassName=t.menuClassName||"highcharts-menu-"+o.btnCount++,r.symbol&&(e=i.symbol(r.symbol,r.symbolX-l/2,r.symbolY-l/2,l,l).addClass("highcharts-button-symbol").attr({zIndex:1}).add(n)).attr({stroke:r.symbolStroke,fill:r.symbolFill,"stroke-width":r.symbolStrokeWidth||1}),n.add().align(E(r,{width:n.width,x:m(r.x,o.buttonOffset)}),!0,"spacingBox"),o.buttonOffset+=(n.width+r.buttonSpacing)*("right"===r.align?-1:1),o.exportSVGElements.push(n,e)}},destroyExport:function(t){var n,o=t?t.target:this,e=o.exportSVGElements,i=o.exportDivElements,r=o.exportEvents;e&&(S(e,function(t,e){t&&(t.onclick=t.ontouchstart=null,n="cache-"+t.menuClassName,o[n]&&delete o[n],o.exportSVGElements[e]=t.destroy())}),e.length=0),i&&(S(i,function(t,e){clearTimeout(t.hideTimer),s(t,"mouseleave"),o.exportDivElements[e]=t.onmouseout=t.onmouseover=t.ontouchstart=t.onclick=null,u(t)}),i.length=0),r&&(S(r,function(t){t()}),r.length=0)}}),r.menu=function(t,e,n,o){return["M",t,e+2.5,"L",t+n,e+2.5,"M",t,e+o/2+.5,"L",t+n,e+o/2+.5,"M",t,e+o-1.5,"L",t+n,e+o-1.5]},e.prototype.renderExporting=function(){var e=this,t=e.options.exporting,n=t.buttons,o=e.isDirtyExporting||!e.exportSVGElements;e.buttonOffset=0,e.isDirtyExporting&&e.destroyExport(),o&&!1!==t.enabled&&(e.exportEvents=[],i(n,function(t){e.addButton(t)}),e.isDirtyExporting=!1),b(e,"destroy",e.destroyExport)},e.prototype.callbacks.push(function(o){function i(t,e,n){o.isDirtyExporting=!0,g(!0,o.options[t],e),m(n,!0)&&o.redraw()}o.renderExporting(),b(o,"redraw",o.renderExporting),S(["exporting","navigation"],function(n){o[n]={update:function(t,e){i(n,t,e)}}})})}(t)});