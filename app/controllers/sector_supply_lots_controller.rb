class SectorSupplyLotsController < ApplicationController
  before_action :set_sector_supply_lot, only: [:show, :destroy, :delete, :restore,
    :restore_confirm, :archive, :archive_confirm, :purge, :purge_confirm]

  # GET /sector_supply_lots
  # GET /sector_supply_lots.json
  def index
    authorize SectorSupplyLot
    @filterrific = initialize_filterrific(
      SectorSupplyLot.lots_for_sector(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: SectorSupplyLot.options_for_sorted_by,
        with_status: SectorSupplyLot.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'insumo_asc'},
      available_filters: [
        :sorted_by,
        :with_status,
        :search_supply_by_name_or_code,
        :with_code,
        :date_received_at
      ],
    ) or return
    @sector_supply_lots = @filterrific.find.page(params[:page]).per_page(15)
  end

  def trash_index
    authorize SectorSupplyLot
    @filterrific = initialize_filterrific(
      SectorSupplyLot.only_deleted.lots_for_sector(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: SectorSupplyLot.options_for_sorted_by,
        with_status: SectorSupplyLot.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'recepcion_desc'},
      available_filters: [
        :sorted_by, :with_status, :search_text, :with_code, :date_received_at
      ],
    ) or return
    @sector_supply_lots = @filterrific.find.page(params[:page]).per_page(15)
  end

  def group_by_supply
    authorize SectorSupplyLot
    @filterrific = initialize_filterrific(
      current_user.sector.supplies,
      params[:filterrific],
      select_options: {
        sorted_by: Supply.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'codigo_asc'},
      available_filters: [
        :sorted_by,
        :search_supply,
        :with_code,
        :with_area_id,
      ],
    ) or return
    @supplies = @filterrific.find.page(params[:page]).per_page(15)

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        send_data generate_stock_report(current_user.sector.supplies),
          filename: 'insumos_stock.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end

  def lots_for_supply
    authorize SectorSupplyLot

    @supply = Supply.with_deleted.find(params[:id])

    @orders = QuantityOrdSupplyLot.orders_to(current_user.sector, @supply.id).sort_by(&:created_at).reverse!
  end

  # GET /sector_supply_lots/1
  # GET /sector_supply_lots/1.json
  def show
    authorize @sector_supply_lot
    _percent = @sector_supply_lot.quantity.to_f / @sector_supply_lot.initial_quantity  * 100 unless @sector_supply_lot.initial_quantity == 0
    @percent_quantity_sector_supply_lot = _percent

    respond_to do |format|
      format.js
    end
  end

  # DELETE /sector_supply_lots/1
  # DELETE /sector_supply_lots/1.json
  def destroy
    authorize @sector_supply_lot
    @supply_name = @sector_supply_lot.supply_name
    @sector_supply_lot.destroy
    respond_to do |format|
      flash.now[:success] = "El lote de "+@supply_name+" se ha enviado a la papelera."
      format.js
    end
  end

  # GET /sector_supply_lot/1/archive
  def archive
    authorize @sector_supply_lot
    
    @sector_supply_lot.archivado!

    respond_to do |format|
      flash.now[:success] = "El lote código "+@sector_supply_lot.code+" se ha archivado correctamente."
      format.js
    end
  end

  # GET /sector_supply_lot/1/restore
  def restore
    authorize @sector_supply_lot
    SectorSupplyLot.restore(@sector_supply_lot.id, :recursive => true)

    respond_to do |format|
      flash.now[:success] = "El lote con código "+@sector_supply_lot.code+" se ha restaurado correctamente."
      format.js
    end
  end

  def purge
    authorize @sector_supply_lot
    @code = @sector_supply_lot.code
    @sector_supply_lot.really_destroy!

    respond_to do |format|
      flash.now[:success] = "El lote con código "+@code+" se ha eliminado definitivamente."
      format.js
    end
  end

  def get_stock_quantity
    @lot = SectorSupplyLot.where(sector_id: current_user.sector_id).with_code(params[:term]).sum(:quantity)
    render json: @lot
  end

  def search_by_code
    @sector_supply_lots = SectorSupplyLot.lots_for_sector(current_user.sector).with_code(params[:term]).limit(10).without_status(3).without_status(4)
    render json: @sector_supply_lots.map{ |sup_lot| { label: sup_lot.code.to_s+" | "+sup_lot.supply_name,
      value: sup_lot.code, id: sup_lot.id, name: sup_lot.supply_name, expiry_date: sup_lot.expiry_date,
      quant: sup_lot.quantity, lot_code: sup_lot.lot_code, lab: sup_lot.laboratory, status_label: sup_lot.status_label } }
  end

  def get_with_code
    @sector_supply_lots = SectorSupplyLot.lots_for_sector(current_user.sector).with_code(params[:term]).without_status(2).without_status(4).sorted_by("vencimiento_asc")
    render json: @sector_supply_lots.map{ |sup_lot| { label: sup_lot.code.to_s+" | "+sup_lot.supply_name,
      value: sup_lot.code, id: sup_lot.id, name: sup_lot.supply_name, expiry_date: sup_lot.expiry_date,
      quant: sup_lot.quantity, lot_code: sup_lot.lot_code } }
  end

  def search_by_name
    @sector_supply_lots = SectorSupplyLot.lots_for_sector(current_user.sector).search_supply_name(params[:term]).limit(10)
    render json: @sector_supply_lots.map{ |sup_lot| { label: sup_lot.supply_name, code: sup_lot.code, id: sup_lot.id, lab: sup_lot.laboratory,
      quant: sup_lot.quantity, expiry_date: sup_lot.expiry_date, value: sup_lot.supply_name, lot_code: sup_lot.lot_code } }
  end

  def select_lot
    @sector_supply_lots = SectorSupplyLot.lots_for_sector(current_user.sector).with_code(params[:supply_id]).without_status(3).without_status(4)
    @selected_lot_id = params[:selected_lot_id]
    @supply_id = params[:supply_id]
    puts "Insumoooooo=>>>>>: "
    puts @supply_id
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sector_supply_lot
      @sector_supply_lot = SectorSupplyLot.with_deleted.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sector_supply_lot_params
      params.require(:sector_supply_lot).permit(:quantity, :expiry_date,
        :supply_lot_id, :supply_id, :lot_code, :laboratory_id)
    end

    def generate_stock_report(supplies)
      report = Thinreports::Report.new
      report.use_layout File.join(Rails.root, 'app', 'reports', 'sector_supply_lot', 'stock.tlf'), :default => true
      report.use_layout File.join(Rails.root, 'app', 'reports', 'sector_supply_lot', 'stock_other_page.tlf'), id: :other_page  
  
      supplies.order(:name).each do |supply|
        if report.page_count == 1 && report.list.overflow?
          report.start_new_page layout: :other_page do |page|
          end
        end

        report.list do |list|
          list.add_row do |row|
            row.values  code: supply.id,
                        supply_name: supply.name,
                        quantity: SectorSupplyLot.where(sector_id: current_user.sector_id).with_supply(supply).sum(:quantity),
                        area: supply.supply_area.name
            end
          
          report.list.on_page_footer_insert do |footer|
            footer.item(:total).value(supplies.count)
          end
        end
      end


      report.pages.each do |page|
        page[:report_date] = DateTime.now.strftime("%d/%m/%Y")
        page[:report_date_footer] = DateTime.now.strftime("%d/%m/%Y")
        page[:page_count] = report.page_count
        page[:sector_establishment] = current_user.sector_and_establishment
        page[:sector_establishment_footer] = current_user.sector_and_establishment
      end
      report.generate
    end
end
