module OriginalChronicPrescriptionsHelper
  
  def row_status_ocpp(ocpp)  
    if ocpp.terminado?
      "success"
    elsif ocpp.terminado_manual?
      "warning"
    end
  end

  # Return the formated delivered percentage
  def delivered_percentage_ocpp(ocpp)
    number_to_percentage(delivered_percentage_value(ocpp), precision: 0, format: "%n%")
  end
  
  # Return the text label of the progress bar
  def progress_label_ocpp(ocpp)
    if ocpp.pendiente?
      delivered_percentage_ocpp(ocpp)
    elsif ocpp.terminado?
      "Terminado"
    elsif ocpp.terminado_manual?
      "Terminado manual"
    end
  end

  # Get the rest percentage when the treatment finished manually
  def end_treatment_percentage_ocpp(ocpp)
    if ocpp.terminado_manual?
      number_to_percentage(100 - delivered_percentage_value(ocpp), precision: 0, format: "%n%")
    else
      return "0%"
    end
  end

  private

  def delivered_percentage_value(ocpp)
    return 0 if ocpp.total_request_quantity <= 0
    (ocpp.total_delivered_quantity * 100) / ocpp.total_request_quantity
  end
end