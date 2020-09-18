class Reports::PatientProductReportsController < ApplicationController

  def new
  end

  def generate
    @movements =  QuantityOrdSupplyLot
                    .where(quantifiable_type: 'Prescription')
                    .joins("INNER JOIN prescriptions ON prescriptions.id = quantity_ord_supply_lots.quantifiable_id")
                    .where("prescriptions.establishment_id = ?", current_user.establishment.id)
                    .where(supply_id: params[:supply_id])
                    .entregado
                    .dispensed_since(params[:since_date])
                    .dispensed_to(params[:to_date])
                    .joins("JOIN patients ON patients.id = prescriptions.patient_id")
                    .group("patients.last_name", "patients.first_name", "patients.dni", "quantity_ord_supply_lots.dispensed_at")
                    .sum(:delivered_quantity)

    @params = params.slice(:supply_id, :since_date, :to_date)

    @supply = Supply.find(params[:supply_id])
    
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        send_data generate_report(@movements, @params),
          filename: 'reporte_producto_por_paciente.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
      format.csv { send_data movements_to_csv(@movements), filename: "reporte-prodcto-paciente-#{Date.today.strftime("%d-%m-%y")}.csv" }
    end
  end

  
  private

    def generate_report(movements, params)
      report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'patient_product', 'first_page.tlf')

      report.use_layout File.join(Rails.root, 'app', 'reports', 'patient_product', 'first_page.tlf'), :default => true
    
      movements.each do |movement|
        if report.page_count == 1 && report.list.overflow?
          report.start_new_page layout: :other_page do |page|
          end
        end
        
        # movement => {["last_name", "first_name", "dni", "dispensed_at"] => "delivered_quantity"} 
        report.list do |list|
          list.add_row do |row|
            row.values  patient_name: movement.first.first+" "+movement.first.second,
                        dni: movement.first.third,
                        delivery_date: movement.first.fourth.strftime("%d/%m/%Y %H:%M"),
                        quantity: movement.second
          end
        end
        
      end
      
  
      report.pages.each do |page|
        page[:product_name] = Supply.find(params[:supply_id]).name
        page[:title] = 'Reporte producto entregado por paciente'
        page[:date_now] = DateTime.now.strftime("%d/%m/%Y")
        page[:since_date] = params[:since_date]
        page[:to_date] = params[:to_date]
        page[:page_count] = report.page_count
        page[:establishment_name] = current_user.establishment_name
        page[:establishment] = current_user.establishment_name
      end
  
      report.generate
    end

    def movements_to_csv(movements)
      CSV.generate(headers: true) do |csv|
        csv << ["Apellido", "Nombre", "DNI", "Fecha", "Cantidad", "Producto"]
        movements.each do |movement|
          csv << [
            movement.first.first, 
            movement.first.second, 
            movement.first.third, 
            movement.first.fourth.strftime("%d/%m/%Y %H:%M"), 
            movement.second,
            Supply.find(params[:supply_id]).name
          ]
        end
      end
    end
end
