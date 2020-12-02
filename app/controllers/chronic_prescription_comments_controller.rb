class ChronicPrescriptionCommentsController < ApplicationController
  before_action :set_chronic_prescription_comment, only: [:show ]

  def show
  end

  def create
    @chronic_prescription_comment = ChronicPrescriptionComment.new()
    authorize @chronic_prescription_comment

    @chronic_prescription_comment.user_id = current_user.id
    @chronic_prescription_comment.chronic_prescription_id = chonic_prescription_comment_params[:order_id]
    @chronic_prescription_comment.text = chonic_prescription_comment_params[:text]

    respond_to do |format|
      if @chronic_prescription_comment.save!
        @count = @chronic_prescription_comment.order.comments.count
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
  def set_chronic_prescription_comment
    @chronic_prescription_comment = ChronicPrescriptionComment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def chonic_prescription_comment_params
    params.require(:chronic_prescription_comment).permit(:order_id, :text)
  end

end
