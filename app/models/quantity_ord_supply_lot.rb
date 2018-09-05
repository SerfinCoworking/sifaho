class QuantityOrdSupplyLot < ApplicationRecord
  # Relaciones
  belongs_to :supply, -> { with_deleted }
  belongs_to :sector_supply_lot, -> { with_deleted }, optional: true
  belongs_to :quantifiable, :polymorphic => true

  # Validaciones
  validates_presence_of :supply
  validates_associated :supply

  accepts_nested_attributes_for :supply
  accepts_nested_attributes_for :sector_supply_lot

  #Métodos públicos
  def increment_lot_to(a_sector)
    if self.sector_supply_lot.present?
      @sector_supply_lot = SectorSupplyLot.where(
        sector_id: a_sector.id,
        supply_lot_id: self.sector_supply_lot.supply_lot_id
      ).first_or_create
      @sector_supply_lot.increment(self.delivered_quantity)
      @sector_supply_lot.save!
    end
  end

  def decrement
    if self.sector_supply_lot.present?
      self.sector_supply_lot.decrement(self.delivered_quantity)
    end
  end

  def increment
    if self.sector_supply_lot.present?
      self.sector_supply_lot.increment(self.delivered_quantity)
    end
  end

  def supply_name
    self.supply.name
  end

  def laboratory
    self.sector_supply_lot.laboratory
  end

  # Retorna el código del insumo del lote
  def supply_code
    self.sector_supply_lot.code
  end

  def lot_code
    self.sector_supply_lot.lot_code
  end

  # Retorna fecha de expiración del lote
  def expiry_date
    self.sector_supply_lot.expiry_date
  end

  # Retorna el tipo de unidad
  def unity
    self.supply.unity
  end
end
