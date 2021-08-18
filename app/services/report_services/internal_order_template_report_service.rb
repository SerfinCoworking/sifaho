module ReportServices
  class InternalOrderTemplateReportService
    def initialize(a_user, an_internal_order)
      @user = a_user
      @internal_order_template = an_internal_order
    end

    def generate_pdf
      report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'internal_order_template', 'first_page.tlf')
      report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order_template', 'second_page.tlf'), id: :other_page

      # Comenzamos con la pagina principal
      report.start_new_page

      report.page[:template_name] = @internal_order_template.name
      report.page[:efector] = @internal_order_template.destination_sector.sector_and_establishment
      report.page[:username].value("DNI: #{@user.dni}, #{@user.full_name}")

      @internal_order_template.internal_order_product_templates.joins(:product).order('name').each do |iots|
        if report.page_count == 1 && report.list.overflow?
          report.start_new_page layout: :other_page
        end

        report.list do |list|
          list.add_row do |row|
            row.item(:product_code).value(iots.product_code)
            row.item(:product_name).value(iots.product_name)
            row.item(:unity_name).value(iots.product.unity_name)
          end
        end
      end

      report.pages.each do |page|
        page[:title] = "Plantilla de #{@internal_order_template.order_type} de sector"
        page[:requested_date] = DateTime.now.strftime('%d/%m/%Y')
        page[:page_count] = report.page_count
      end

      report.generate
    end
  end
end
