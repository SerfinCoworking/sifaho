# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
  #id del form anidado para quantity_supplies
$(document).on "turbolinks:load", ->
  supplies = $('#quantity-supplies')

  #Métodos para conocer la cantitdad de forms anidados
  count = supplies.find('.count > span')
  idNum = -> supplies.find('.nested-fields').size()
  recount = -> count.text supplies.find('.nested-fields').size()
  recount()

  supplies.on 'cocoon:before-insert', (e, el_to_add) ->
    el_to_add.fadeIn(200) #Efecto para el insert

  supplies.on 'cocoon:after-insert', (e, added_el) ->
    #Se coloca el id de los campos anidados
    console.log("hola")
    added_el.find('select').attr("id", "chosen-supply-"+idNum())
    added_el.find('input.form-control.numeric').attr("id", "quantity-supply-"+idNum())
    recount()
    for i in [1..idNum()]
      selectedValue = $("#chosen-supply-"+i+" option:selected").val()
      for x in [1..idNum()]
        if x != i
          $("#chosen-supply-"+x).find('option[value="'+selectedValue+'"]:not(:selected)').attr('disabled','disabled')
          $("#chosen-supply-"+x).trigger("chosen:updated")

  supplies.on 'cocoon:before-remove', (e, el_to_remove) ->
    $(this).data('remove-timeout', 200)#Efecto para remover
    el_to_remove.fadeOut(200)

  supplies.on 'cocoon:after-remove', (e, removed_el) ->
    recount() #Se vuelve a contar la cantidad de forms
