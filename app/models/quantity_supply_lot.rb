class QuantitySupplyLot < ApplicationRecord
  # Relaciones
  belongs_to :sector_supply_lot, -> { with_deleted }
  belongs_to :quantifiable, :polymorphic => true

  # Validaciones
  validates_presence_of :sector_supply_lot
  validates_associated :sector_supply_lot

  accepts_nested_attributes_for :sector_supply_lot

  #Métodos públicos
  def increment_lot_to(a_sector)
    @sector_supply_lot = SectorSupplyLot.where(
      sector_id: a_sector.id,
      supply_lot_id: self.sector_supply_lot.supply_lot_id
    ).first_or_create
    @sector_supply_lot.increment(self.quantity)
    @sector_supply_lot.save!
  end

  def decrement
      self.sector_supply_lot.decrement(self.quantity)
  end


  def supply_name
    self.sector_supply_lot.supply_name
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
    self.sector_supply_lot.unity
  end
end
