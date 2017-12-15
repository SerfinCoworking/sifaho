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
