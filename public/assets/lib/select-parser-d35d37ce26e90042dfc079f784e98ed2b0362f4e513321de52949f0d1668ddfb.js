(function(){var a;(a=function(){function e(){this.options_index=0,this.parsed=[]}return e.prototype.add_node=function(e){return"OPTGROUP"===e.nodeName.toUpperCase()?this.add_group(e):this.add_option(e)},e.prototype.add_group=function(e){var t,s,i,d,n,a;for(t=this.parsed.length,this.parsed.push({array_index:t,group:!0,label:e.label,title:e.title?e.title:void 0,children:0,disabled:e.disabled,classes:e.className}),a=[],s=0,i=(n=e.childNodes).length;s<i;s++)d=n[s],a.push(this.add_option(d,t,e.disabled));return a},e.prototype.add_option=function(e,t,s){if("OPTION"===e.nodeName.toUpperCase())return""!==e.text?(null!=t&&(this.parsed[t].children+=1),this.parsed.push({array_index:this.parsed.length,options_index:this.options_index,value:e.value,text:e.text,html:e.innerHTML,title:e.title?e.title:void 0,selected:e.selected,disabled:!0===s?s:e.disabled,group_array_index:t,group_label:null!=t?this.parsed[t].label:null,classes:e.className,style:e.style.cssText})):this.parsed.push({array_index:this.parsed.length,options_index:this.options_index,empty:!0}),this.options_index+=1},e}()).select_to_array=function(e){var t,s,i,d,n;for(d=new a,s=0,i=(n=e.childNodes).length;s<i;s++)t=n[s],d.add_node(t);return d.parsed},window.SelectParser=a}).call(this);