# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on "turbolinks:load", ->
  $('#dialog').on 'shown.bs.modal', (e) ->
    # Fix para asignar estilo al chosen de los nuevos forms anidados
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
        newContent.find('.chosen-select').chosen(width: '270px')
