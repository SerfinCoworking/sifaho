module ReportServices

  class OutpatientPrescriptionReportService
    def initialize(a_user, a_prescription)
      @user = a_user
      @prescription = a_prescription
    end

    def generate_pdf
      report = Thinreports::Report.new

      report.use_layout File.join(Rails.root, 'app', 'reports', 'outpatient_prescription', 'other_page.tlf'), default: true
      report.use_layout File.join(Rails.root, 'app', 'reports', 'outpatient_prescription', 'first_page.tlf'), id: :cover_page

      # Start with the main layout
      report.start_new_page layout: :cover_page

      # Add the header
      report.page[:title] = 'Receta ambulatoria'
      report.page[:remit_code] = @prescription.remit_code
      report.page[:prescribed_date] = @prescription.date_prescribed.strftime('%d/%m/%Y')
      report.page[:expiry_date] = @prescription.expiry_date.strftime('%d/%m/%Y')
      report.page[:patient_fullname] = @prescription.patient_fullname.titleize
      report.page[:patient_dni] = @prescription.patient_dni
      report.page[:patient_age] = @prescription.patient_age_string
      report.page[:professional_fullname] = @prescription.professional_fullname
      report.page[:professional_qualifications] = @prescription.professional_qualifications.map { |pq| ["#{pq.name} #{pq.code}"] }.join(', ')
      report.page[:observations] = @prescription.observation
      report.page[:user_info].value("DNI: #{@user.dni}, #{@user.full_name}")

      # Add the products
      @prescription.outpatient_prescription_products.joins(:product).order('name').each do |eop|
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
                    observation: eop.observation

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
