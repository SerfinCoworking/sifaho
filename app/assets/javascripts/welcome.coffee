# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#Fix para asignar estilo al chosen de medicamentos
jQuery ($) ->
  $('.add_fields').each ->
    $this              = $(this)
    insertionNode      = $this.data('association-insertion-node')
    insertionTraversal = $this.data('association-insertion-traversal')

    if (insertionNode)
      if (insertionTraversal)
        insertionNode = $this[insertionTraversal](insertionNode)
      else
        insertionNode = insertionNode == "this" ? $this : $(insertionNode)
    else
      insertionNode = $this.parent()

    insertionNode.bind 'cocoon:after-insert', (e, newContent) ->
      newContent.find('.chosen-select').chosen(width: '300px')


$(document).on "turbolinks:load", ->
  # habilitar chosen js
  $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No se encontró el resultado'
    width: '300px'

  #id del form anidado para quantity_medications
  medications = $('#quantity-medications')

  #Métodos para conocer la cantitdad de forms anidados
  count = medications.find('.count > span')
  idNum = -> medications.find('.nested-fields').size()
  recount = -> count.text medications.find('.nested-fields').size()
  recount()

  medications.on 'cocoon:before-insert', (e, el_to_add) ->
    el_to_add.fadeIn(200) #Efecto para el insert

  medications.on 'cocoon:after-insert', (e, added_el) ->
    #Se coloca el id de los campos anidados
    added_el.find('select').attr("id", "chosen-medication-"+idNum())
    added_el.find('input.form-control.numeric').attr("id", "quantity-medication-"+idNum())
    recount()

  medications.on 'cocoon:before-remove', (e, el_to_remove) ->
    $(this).data('remove-timeout', 200)#Efecto para remover
    el_to_remove.fadeOut(200)

  medications.on 'cocoon:after-remove', (e, removed_el) ->
    recount() #Se vuelve a contar la cantidad de forms
