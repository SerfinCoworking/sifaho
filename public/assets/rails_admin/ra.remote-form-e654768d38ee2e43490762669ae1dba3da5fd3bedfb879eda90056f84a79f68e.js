!function(r){r.widget("ra.remoteForm",{_create:function(){var i=this,t=i.element,n=t.find("select").first().data("options")&&t.find("select").first().data("options")["edit-url"];void 0!==n&&n.length&&t.on("dblclick",".ra-multiselect option:not(:disabled)",function(e){i._bindModalOpening(e,n.replace("__ID__",this.value))}),t.find(".create").unbind().bind("click",function(e){i._bindModalOpening(e,r(this).data("link"))}),t.find(".update").unbind().bind("click",function(e){(value=t.find("select").val())?i._bindModalOpening(e,r(this).data("link").replace("__ID__",value)):e.preventDefault()})},_bindModalOpening:function(e,i){if(e.preventDefault(),widget=this,r("#modal").length)return!1;var t=this._getModal();setTimeout(function(){r.ajax({url:i,beforeSend:function(e){e.setRequestHeader("Accept","text/javascript")},success:function(e){t.find(".modal-body").html(e),widget._bindFormEvents()},error:function(e){t.find(".modal-body").html(e.responseText)},dataType:"text"})},200)},_bindFormEvents:function(){var o=this,s=this._getModal(),e=s.find("form"),i=s.find(":submit[name=_save]").html(),t=s.find(":submit[name=_continue]").html();s.find(".form-actions").remove(),e.attr("data-remote",!0),s.find(".modal-header-title").text(e.data("title")),s.find(".cancel-action").unbind().click(function(){return s.modal("hide"),!1}).html(t),s.find(".save-action").unbind().click(function(){return e.submit(),!1}).html(i),r(document).trigger("rails_admin.dom_ready",[e]),e.bind("ajax:complete",function(e,i,t){if("error"==t)s.find(".modal-body").html(i.responseText),o._bindFormEvents();else{var n=r.parseJSON(i.responseText),d='<option value="'+n.id+'" selected>'+n.label+"</option>",a=o.element.find("select").filter(":hidden");if(o.element.find(".filtering-select").length){o.element.find(".filtering-select").children(".ra-filtering-select-input").val(n.label),a.find("option[value="+n.id+"]").length||(a.html(d).val(n.id),o.element.find(".update").removeClass("disabled"))}else{o.element.find(".ra-filtering-select-input");var l=o.element.find(".ra-multiselect");l.find("option[value="+n.id+"]").length?(a.find("option[value="+n.id+"]").text(n.label),l.find("option[value= "+n.id+"]").text(n.label)):(a.append(d),l.find("select.ra-multiselect-selection").append(d))}o._trigger("success"),s.modal("hide")}})},_getModal:function(){var e=this;return e.dialog||(e.dialog=r('<div id="modal" class="modal fade">            <div class="modal-dialog">            <div class="modal-content">            <div class="modal-header">              <a href="#" class="close" data-dismiss="modal">&times;</a>              <h3 class="modal-header-title">...</h3>            </div>            <div class="modal-body">              ...            </div>            <div class="modal-footer">              <a href="#" class="btn cancel-action">...</a>              <a href="#" class="btn btn-primary save-action">...</a>            </div>            </div>            </div>          </div>').modal({keyboard:!0,backdrop:!0,show:!0}).on("hidden.bs.modal",function(){e.dialog.remove(),e.dialog=null})),this.dialog}})}(jQuery);