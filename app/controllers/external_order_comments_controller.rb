class ExternalOrderCommentsController < ApplicationController
  before_action :set_external_order_comment, only: [:show ]

  def show
  end

  def create
    @external_order_comment = ExternalOrderComment.new(external_order_comment_params)
    authorize @external_order_comment

    @external_order_comment.user = current_user

    respond_to do |format|
      if @external_order_comment.save!
        @count = @external_order_comment.order.comments.count
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
  def set_external_order_comment
    @external_order_comment = ExternalOrderComment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def external_order_comment_params
    params.require(:external_order_comment).permit(:order_id, :text)
  end

end
