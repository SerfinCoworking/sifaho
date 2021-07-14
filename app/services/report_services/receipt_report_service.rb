module ReportServices

  class ReceiptReportService
    def initialize(a_user, a_receipt)
      @user = a_user
      @receipt = a_receipt
    end

    def generate_pdf
      report = Thinreports::Report.new
      report.use_layout File.join(Rails.root, 'app', 'reports', 'receipt', 'other_page.tlf'), default: true
      report.use_layout File.join(Rails.root, 'app', 'reports', 'receipt', 'first_page.tlf'), id: :cover_page
      # Comenzamos con la pagina principal
      report.start_new_page layout: :cover_page

      # Agregamos el encabezado
      report.page[:title] = "Recibo #{@receipt.code}"
      report.page[:requested_date] = @receipt.created_at.strftime('%d/%m/%YY')
      report.page[:efector] = "#{@user.sector_name} #{@user.establishment_name}"
      report.page[:username].value("DNI: #{@user.dni}, #{@user.full_name}")
      report.page[:products_count].value(@receipt.receipt_products.count)

      # Se van agregando los productos
      @receipt.receipt_products.each do |r_product|
        # Luego de que la primer pagina ya halla sido rellenada, agregamos la pagina defualt (no tiene header)
        report.start_new_page if report.page_count == 1 && report.list.overflow?

        report.list do |list|
          list.add_row do |row|
            row.values(
              product_code: r_product.product_code,
              product_name: r_product.product_name,
              quantity: "#{r_product.quantity} #{r_product.product_unity_name.pluralize(r_product.quantity)}",
              provenance: r_product.provenance_name,
              lot_code: r_product.lot_code.present? ? r_product.lot_code : 'n/a',
              laboratory: r_product.laboratory_name,
              expiry_date: r_product.expiry_date.present? ? r_product.expiry_date.strftime('%m/%y') : 'No vence'
            )
          end
        end
      end

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
