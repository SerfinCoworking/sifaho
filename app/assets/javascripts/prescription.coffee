$(document).on "turbolinks:load", ->
  $('#dialog').on 'shown.bs.modal', (e) ->
    # Id del form anidado para quantity_medications
    medications = $('#quantity-medications')

    # Métodos para conocer la cantitdad de forms anidados
    idNum = -> medications.find('.nested-fields').size()

    medications.on 'cocoon:before-insert', (e, el_to_add) ->
      el_to_add.fadeIn(200) # Efecto para el insert

    medications.on 'cocoon:after-insert', (e, added_el) ->
      # Se coloca el id de los campos anidados
      added_el.find('select').attr("id", "chosen-medication-"+idNum())
      added_el.find('input.form-control.numeric').attr("id", "quantity-medication-"+idNum())
      for i in [1..idNum()]
        selectedValue = $("#chosen-medication-"+i+" option:selected").val()
        for x in [1..idNum()]
          if x != i
            $("#chosen-medication-"+x).find('option[value="'+selectedValue+'"]:not(:selected)').attr('disabled','disabled')
            $("#chosen-medication-"+x).trigger("chosen:updated")


    medications.on 'cocoon:before-remove', (e, el_to_remove) ->
      $(this).data('remove-timeout', 200)# Efecto para remover
      el_to_remove.fadeOut(200)

    medications.on 'cocoon:after-remove', (e, removed_el) ->
