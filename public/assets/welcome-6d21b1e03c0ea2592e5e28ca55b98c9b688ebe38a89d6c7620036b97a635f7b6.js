(function() {
  $(document).on("turbolinks:load", function() {
    return $('#dialog').on('shown.bs.modal', function(e) {
      return $('.add_fields').each(function() {
        var $this, insertionNode, insertionTraversal, ref;
        $this = $(this);
        insertionNode = $this.data('association-insertion-node');
        insertionTraversal = $this.data('association-insertion-traversal');
        if (insertionNode) {
          if (insertionTraversal) {
            insertionNode = $this[insertionTraversal](insertionNode);
          } else {
            insertionNode = (ref = insertionNode === "this") != null ? ref : {
              $this: $(insertionNode)
            };
          }
        } else {
          insertionNode = $this.parent();
        }
        return insertionNode.bind('cocoon:after-insert', function(e, newContent) {
          return newContent.find('.chosen-select').chosen({
            width: '270px'
          });
        });
      });
    });
  });

}).call(this);
