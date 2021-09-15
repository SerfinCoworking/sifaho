module ReportServices

  class OutpatientPrescriptionReportService
    def initialize(a_user, a_prescription)
      @user = a_user
      @prescription = a_prescription
    end

    def generate_pdf
      report = Thinreports::Report.new

      report.use_layout File.join(Rails.root, 'app', 'reports', 'external_order', 'other_page.tlf'), default: true
      report.use_layout File.join(Rails.root, 'app', 'reports', 'external_order', 'first_page.tlf'), id: :cover_page

      # Comenzamos con la pagina principal
      report.start_new_page layout: :cover_page

      # Agregamos el encabezado
      report.page[:title] = 'Pedido de establecimiento'
      report.page[:remit_code] = @prescription.remit_code
      report.page[:requested_date] = @prescription.requested_date.strftime('%d/%m/%YY')
      report.page[:patient_fullname] = @prescription.patient_fullname.titleize
      report.page[:patient_dni] = @prescription.patient_dni
      report.page[:patient_age] = @prescription.patient_age_string
      report.page[:provider_efector] = @prescription.provider_sector.sector_and_establishment
      report.page[:provider_user] = @prescription.sent_provision_by_user_fullname
      report.page[:observations] = @prescription.observation
      report.page[:products_count].value(@prescription.order_products.count)
      report.page[:observations_count].value("solicitante "+@prescription.order_products.where.not(applicant_observation: [nil, ""]).count.to_s+" / proveedor "+@prescription.order_products.where.not(provider_observation: [nil, ""]).count.to_s)

      # Se van agregando los productos
      @prescription.order_products.joins(:product).order("name").each do |eop|  
        # Luego de que la primer pagina ya halla sido rellenada, agregamos la pagina defualt (no tiene header)
        report.start_new_page if report.page_count == 1 && report.list.overflow?

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
        page[:sector] = @user.sector_name
        page[:establishment] = @user.establishment_name
      end

      report.generate
    end
  end
end
