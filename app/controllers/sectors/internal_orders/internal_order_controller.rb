class Sectors::InternalOrders::InternalOrderController < ApplicationController

  # def statistics
  #   @internal_providers = InternalOrder.provider(current_user.sector)
  #   @internal_applicants = InternalOrder.applicant(current_user.sector)
  # end

  # GET /internal_orders/1
  # GET /internal_orders/1.json
  def show
    authorize @internal_order
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        send_data generate_order_report(@internal_order),
          filename: 'Pedido_interno_'+@internal_order.remit_code+'.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end

  # DELETE /internal_orders/1
  # DELETE /internal_orders/1.json
  def destroy
    @internal_order.destroy
    respond_to do |format|
      @internal_order.create_notification(current_user, 'se eliminó correctamente')
      flash.now[:success] = 'El pedido interno de se ha eliminado correctamente.'
      format.js
    end
  end

  def generate_order_report(internal_order)
    report = Thinreports::Report.new

    report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order', 'other_page.tlf'), :default => true
    report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order', 'first_page.tlf'), id: :cover_page
    
    # Comenzamos con la pagina principal
    report.start_new_page layout: :cover_page

    # Agregamos el encabezado
    report.page[:title] = 'Reporte de '+internal_order.order_type.humanize.underscore
    report.page[:remit_code] = internal_order.remit_code
    report.page[:requested_date] = internal_order.requested_date.strftime('%d/%m/%YY')
    report.page[:applicant_sector] = internal_order.applicant_sector.name
    report.page[:provider_sector] = internal_order.provider_sector.name
    report.page[:observations] = internal_order.observation
    report.page[:total_products] = internal_order.order_products.count.to_s+" "+"producto".pluralize(internal_order.order_products.size)
  

    # Se van agregando los productos
    internal_order.order_products.joins(:product).order("name").each do |eop|  
      # Luego de que la primer pagina ya halla sido rellenada, agregamos la pagina defualt (no tiene header)
      
      if report.page_count == 1 && report.list.overflow?
        report.start_new_page
      end

      report.list do |list|
        if eop.order_prod_lot_stocks.present?
          eop.order_prod_lot_stocks.each_with_index do |opls, index|
            if index == 0
              list.add_row do |row|
                row.values  lot_code: opls.lot_stock.lot.code,
                  expiry_date: opls.lot_stock.lot.expiry_date.present? ? opls.lot_stock.lot.expiry_date.strftime("%m/%y") : '----',
                  lot_q: "#{opls.quantity} #{eop.product.unity.name.pluralize(opls.quantity)}"
                row.values  product_code: eop.product.code,
                  product_name: eop.product.name,
                  requested_quantity: eop.request_quantity.to_s+" "+eop.product.unity.name.pluralize(eop.request_quantity),
                  obs_req: eop.applicant_observation,
                  obs_del: eop.provider_observation
        
                row.item(:border).show if eop.order_prod_lot_stocks.count == 1
              end
            else                
              list.add_row do |row|
                row.values  lot_code: opls.lot_stock.lot.code,
                expiry_date: opls.lot_stock.lot.expiry_date.present? ? opls.lot_stock.lot.expiry_date.strftime("%m/%y") : '----',
                lot_q: "#{opls.quantity} #{eop.product.unity.name.pluralize(opls.quantity)}"
        
                row.item(:border).show if eop.order_prod_lot_stocks.last == opls
              end
            end
          end
        else
          list.add_row do |row|
            row.values  product_code: eop.product.code,
            product_name: eop.product.name,
            requested_quantity: eop.request_quantity.to_s+" "+eop.product.unity.name.pluralize(eop.request_quantity),
            obs_req: eop.applicant_observation,
            obs_del: eop.provider_observation
            row.item(:border).show
          end
        end
      end # fin lista      
    end # fin productos

    # A cada pagina le agregamos el pie de pagina
    report.pages.each do |page|
      page[:page_count] = report.page_count
      page[:sector] = current_user.sector_name
      page[:establishment] = current_user.establishment_name
    end

    report.generate
  end

  def set_order_product
    @order_product = params[:order_product_id].present? ? InternalOrderProduct.find(params[:order_product_id]) : InternalOrderProduct.new
  end

  protected

  # Use callbacks to share common setup or constraints between actions.
  def set_internal_order
    @internal_order = InternalOrder.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def internal_order_params
    params.require(:internal_order).permit(
      :applicant_sector_id, 
      :sent_by_id, 
      :order_type,
      :provider_sector_id, 
      :requested_date, 
      :date_received, 
      :observation, 
      :remit_code,
      order_products_attributes: [
        :id, 
        :product_id, 
        :lot_stock_id,
        :request_quantity,
        :delivery_quantity,
        :applicant_observation,
        :provider_observation, 
        :_destroy,
        order_prod_lot_stocks_attributes: [
          :id,
          :quantity,
          :lot_stock_id,
          :_destroy
        ]
      ]
    )
  end

  def new_from_template(template_id, order_type)
    # Buscamos el template
    @internal_order_template = InternalOrderTemplate.find_by(id: template_id, order_type: order_type)
    @internal_order = InternalOrder.new
    @internal_order.order_type = @internal_order_template.order_type

    if @internal_order.provision?
      @internal_order.applicant_sector = @internal_order_template.destination_sector
    else
      @internal_order.provider_sector = @internal_order_template.destination_sector
    end

    # Seteamos los productos a la orden
    @internal_order_template.internal_order_product_templates.joins(:product).order("name").each do |iots|
      @internal_order.order_products.build(product_id: iots.product_id)
    end

    # Establecemos la opciones del selector de sector
    @sectors = Sector
    .select(:id, :name)
    .with_establishment_id(@internal_order_template.destination_sector.establishment.id)
    .where.not(id: current_user.sector_id)
  end

  def sending?
    return params[:commit] == 'sending'
  end
end
