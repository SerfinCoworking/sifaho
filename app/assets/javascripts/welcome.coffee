# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#Fix para el estilo de agregar nuevos medicamentos en el chosen
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
  # enable chosen js
  $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No se encontró el resultado'
    width: '300px'

  medications = $('#quantity-medications')

  count = medications.find('.count > span')

  idNum = -> medications.find('.nested-fields').size()

  recount = -> count.text medications.find('.nested-fields').size()
  recount()
  medications.on 'cocoon:before-insert', (e, el_to_add) ->
    el_to_add.fadeIn(200)

  medications.on 'cocoon:after-insert', (e, added_el) ->
    #Set id of nested fields
    console.log("jquery")
    added_el.find('select').attr("id", "chosen-medication-"+idNum())
    added_el.find('input.form-control.numeric').attr("id", "quantity-medication-"+idNum())
    recount()

  medications.on 'cocoon:before-remove', (e, el_to_remove) ->
    $(this).data('remove-timeout', 200)
    el_to_remove.fadeOut(200)

  medications.on 'cocoon:after-remove', (e, removed_el) ->
    recount()

  addChange = ->
    for i in [1 .. idNum()]
      $("#chosen-medication"+idNum()).change ->
      if $("#chosen-medication"+idNum()+" option:selected").val() == 0
        console.log("hola1")
        document.getElementById('#form-prescription').style.display="block";
        document.getElementById('patientHint').style.display="none";
      else
        console.log("hola2")
        document.getElementById('form-prescription').style.display="none";
        document.getElementById('patientHint').style.display="block";
