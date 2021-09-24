class LotArchivesController < ApplicationController
  before_action :set_lot_archive, only: %i[show]
  before_action :set_lot_stock, only: %i[new create]

  def show
    authorize @lot_archive
  end

  def new
    authorize LotArchive

    @lot_archive = LotArchive.new
    respond_to do |format|
      format.js
    end
  end

  def create
    @lot_archive = LotArchive.new(lot_archive_params)
    @lot_archive.user_id = current_user.id
    authorize @lot_archive

    respond_to do |format|
      if @lot_archive.save
        format.html { redirect_to @lot_archive, notice: 'Lote archivado correctamente.' }
      else
        format.js { render :new }
      end
    end
  end

  private

  def set_lot_archive
    @lot_archive = LotArchive.find(params[:id])
  end

  def set_lot_stock
    @lot_stock = LotStock.find(params[:id])
  end

  def lot_archive_params
    params.require(:lot_archive).permit(%i[lot_stock_id quantity observation])
  end
end
