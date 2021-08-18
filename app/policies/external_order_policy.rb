class ExternalOrderPolicy < ApplicationPolicy
  def index?
    show?
  end

  # def applicant_index?
  #   show?
  # end

  def show?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
  end

  def edit?
  end

  # new version
 
  

  

  def show_applicant_fields?
    if record.solicitud_auditoria?
      record.solicitud? && (new_applicant? || edit_applicant?)
    end
  end

  def show_provider_fields?
    # asd
    if record.provision?
      return new_provider? || edit_provider?
    else
      return edit_provider?
    end
  end
  #  end new version


  def new_report?
    new_report.any? { |role| user.has_role?(role) }
  end

  def generate_report?
    new_report?
  end

  def destroy?
    if destroy_pres.any? { |role| user.has_role?(role) }
      if record.provision? && record.proveedor_auditoria?
        return record.provider_sector == user.sector
      elsif record.solicitud? && record.solicitud_auditoria?
        return record.applicant_sector == user.sector
      end 
    end 
  end

  def delete?
    destroy?
  end

  def receive?
    dispense_pres.any? { |role| user.has_role?(role) }
  end
  
  


  def receive_applicant?
    if record.applicant_sector == user.sector && record.provision_en_camino? 
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  
  
  
  
  ####### TO REVIEW ######


  def return_status?
    if destroy_pres.any? { |role| user.has_role?(role) }
      if record.despacho?
        if record.proveedor_aceptado? || record.provision_en_camino?
          return record.provider_sector == user.sector
        end
      elsif record.solicitud_abastecimiento?
        if record.proveedor_aceptado?
          return record.provider_sector == user.sector
        elsif record.solicitud_enviada?
          return record.applicant_sector == user.sector
        elsif record.provision_en_camino?
          return record.provider_sector == user.sector
        end
      elsif record.recibo?
        return false
      end
    end 
  end
  
 

  private
  
  def receive_order
    [ :admin, :farmaceutico ]
  end



  

  
  def new_report
    [ :admin, :farmaceutico ]
  end

  def send_order
    [ :admin, :farmaceutico, :auxiliar_farmacia, :enfermero ]
  end

  def return_status
    [ :admin, :farmaceutico, :auxiliar_farmacia, :enfermero ]
  end

  def update_pres
    [ :admin, :farmaceutico, :auxiliar_farmacia, :enfermero ]
  end

  def see_pres
    [ :admin, :farmaceutico, :auxiliar_farmacia, :enfermero, :medic ]
  end

  def new_pres
    [ :admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero ]
  end

  def destroy_pres
    [ :admin, :farmaceutico, :enfermero ]
  end

  def dispense_pres
    [ :admin, :farmaceutico, :auxiliar_farmacia, :enfermero ]
  end
end
