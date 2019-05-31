class OrderingSupplyPolicy < ApplicationPolicy
  def index?
    see_pres.any? { |role| user.has_role?(role) }
  end

  def applicant_index?
    index?
  end

  def show?
    index?
  end

  def create_receipt?
    create_receipt.any? { |role| user.has_role?(role) }
  end

  def create?
    new_pres.any? { |role| user.has_role?(role) }
  end

  def new?
    create?
  end

  def new_report?
    new_report.any? { |role| user.has_role?(role) }
  end

  def generate_report?
    new_report?
  end


  def update?
    if update_pres.any? { |role| user.has_role?(role) }
      if record.despacho?
        if record.proveedor_aceptado? || record.proveedor_auditoria?
          return record.provider_sector == user.sector
        end
      elsif record.solicitud_abastecimiento? && record.solicitud_enviada?
        return record.provider_sector == user.sector
      elsif (record.solicitud_abastecimiento? && record.proveedor_auditoria?) || (record.solicitud_abastecimiento? && record.proveedor_aceptado?)
        return record.provider_sector == user.sector
      elsif record.solicitud_abastecimiento? && record.solicitud_auditoria?
        return record.applicant_sector == user.sector
      elsif record.recibo? && record.recibo_auditoria?
        return record.applicant_sector == user.sector
      end
    end
  end

  def edit?
    if (["solicitud_enviada", "proveedor_auditoria"].include? record.status) && record.provider_sector == user.sector
      edit_provider.any? { |role| user.has_role?(role) }
    end
  end

  def edit_receipt?
    if record.recibo_auditoria? && record.applicant_sector == user.sector
      edit_provider.any? { |role| user.has_role?(role) }
    end
  end

  def edit_applicant?
    if record.solicitud_auditoria? && record.applicant_sector == user.sector
      edit_applicant.any? { |role| user.has_role?(role) }
    end
  end

  def destroy?
    if destroy_pres.any? { |role| user.has_role?(role) }
      if record.despacho? && record.proveedor_auditoria?
        return record.provider_sector == user.sector
      elsif record.solicitud_abastecimiento? && record.solicitud_auditoria?
        return record.applicant_sector == user.sector
      elsif record.recibo? && record.recibo_auditoria?
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
  
  def new_applicant?
    new_applicant.any? { |role| user.has_role?(role) }
  end
  
  def new_receipt?
    new_receipt.any? { |role| user.has_role?(role) }
  end

  def new_provider?
    new_provider.any? { |role| user.has_role?(role) }
  end

  def send_provider?
    if record.provider_sector == user.sector
      record.proveedor_aceptado? && send_order.any? { |role| user.has_role?(role) }
    end
  end

  def send_applicant?
    if record.applicant_sector == user.sector
      record.provider_aceptado? && send_order.any? { |role| user.has_role?(role) }
    end
  end

  def receive_order?
    if record.applicant_sector == user.sector && receive_order.any? { |role| user.has_role?(role) }
      if record.recibo?
        record.recibo_auditoria?
      elsif record.despacho? || record.solicitud_abastecimiento?
        record.provision_en_camino?
      end
    end
  end

  def return_status?
    if destroy_pres.any? { |role| user.has_role?(role) }
      if record.despacho?
        if record.proveedor_aceptado? || record.provision_en_camino?
          return record.provider_sector == user.sector
        end
      elsif record.solicitud_abastecimiento? && record.proveedor_aceptado?
        return record.provider_sector == user.sector
      elsif record.solicitud_abastecimiento? && record.solicitud_enviada?
        return record.applicant_sector == user.sector
      elsif record.recibo?
        return false
      end
    end 
  end

  private
  def create_receipt
    [ :admin, :farmaceutico ]
  end
  
  def receive_order
    [ :admin, :farmaceutico ]
  end

  def edit_provider
    [ :admin, :farmaceutico, :enfermero ]
  end

  def edit_applicant
    [ :admin, :farmaceutico, :enfermero ]
  end

  def new_provider
    [ :admin, :farmaceutico, :enfermero ]
  end

  def new_applicant
    [ :admin, :farmaceutico, :enfermero ]
  end

  def new_receipt
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
