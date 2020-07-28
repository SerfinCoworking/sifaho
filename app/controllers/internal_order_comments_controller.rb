class InternalOrderCommentsController < ApplicationController
  before_action :set_internal_order_comment, only: [:show ]

  def show
  end

  def create
    @internal_order_comment = InternalOrderComment.new(internal_order_comment_params)
    authorize @internal_order_comment

    @internal_order_comment.user = current_user

    respond_to do |format|
      if @internal_order_comment.save!
        @count = @internal_order_comment.order.comments.count
        flash.now[:success] = "El comentario se ha enviado correctamente."
        format.js
      else
        flash[:error] = "El comentario no se ha podido enviar."
        format.js { render layout: false, content_type: 'text/javascript' }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_internal_order_comment
    @internal_order_comment = InternalOrderComment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def internal_order_comment_params
    params.require(:internal_order_comment).permit(:order_id, :text)
  end

end
