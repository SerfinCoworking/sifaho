class Reports::PatientProductReportsController < ApplicationController

  def new
  end

  def generate
    @movements =  QuantityOrdSupplyLot
                    .where(quantifiable_type: 'Prescription')
                    .where(supply_id: params[:supply_id])
                    .entregado
                    .dispensed_since(params[:since_date])
                    .dispensed_to(params[:to_date])
                    .joins("INNER JOIN prescriptions ON prescriptions.id = quantity_ord_supply_lots.quantifiable_id")
                    .joins("JOIN patients ON patients.id = prescriptions.patient_id")
                    .group("patients.last_name", "patients.first_name", "patients.dni", "quantity_ord_supply_lots.dispensed_at")
                    .sum(:delivered_quantity)

    @params = params.slice(:supply_id, :since_date, :to_date)

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        send_data generate_report(@movements, @params),
          filename: 'reporte_producto_por_paciente.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end

  
  private

    def generate_report(movements, params, establishment_name = current_user.establishment_name)
      report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'prescription', 'first_page.tlf')

      report.use_layout File.join(Rails.root, 'app', 'reports', 'patient_product', 'first_page.tlf'), :default => true
    
      @movements.each do |movement|
        if report.page_count == 1 && report.list.overflow?
          report.start_new_page layout: :other_page do |page|
          end
        end

        # movement => {["last_name", "first_name", "dni", "dispensed_at"] => "delivered_quantity"}
        report.list do |list|
          list.add_row do |row|
            row.values  patient_name: movement.first.first+' '+movement.first.second,
                        dni: movement.first.third,
                        delivery_date: movement.first.fourth.strftime("%d/%m/%Y"),
                        quantity: movement.second
          end
        end
        
        if report.page_count == 1

          report.page[:establishment_name] = establishment_name
          report.page[:report_date] = Date.today.strftime("%d/%m/%Y")
          
          report.page[:professional_name] = movement.professional.fullname
          report.page[:professional_dni] = movement.professional.dni
          report.page[:professional_enrollment] = movement.professional.enrollment
          report.page[:professional_phone] = movement.professional.phone

          report.page[:patien_name] = "#{movement.patient.first_name} #{movement.patient.last_name}"
          report.page[:patien_dni] = movement.patient.dni
        end
      end
    end
end
