class QuantityOrdSupplyLot < ApplicationRecord
  enum status: { sin_entregar: 0, entregado: 1, sin_stock: 2 }

  # Relaciones
  belongs_to :supply, -> { with_deleted }
  belongs_to :sector_supply_lot, -> { with_deleted }, optional: true
  belongs_to :supply_lot, -> { with_deleted }, optional: true
  belongs_to :quantifiable, :polymorphic => true
  has_one :sector, :through => :sector_supply_lot

  # Validaciones
  validates_presence_of :supply
  validates_presence_of :requested_quantity
  validates_presence_of :delivered_quantity
  validates_associated :supply

  accepts_nested_attributes_for :supply,
  :allow_destroy => true,
  :reject_if => proc { |att| att[:supply_id].blank? }
  accepts_nested_attributes_for :sector_supply_lot,
  :reject_if => :all_blank,
  :allow_destroy => true
  accepts_nested_attributes_for :supply_lot,
  :allow_destroy => true,
  :reject_if => proc { |att| att[:supply_lot_id].blank? }
  
  # Métodos públicos
  def increment_lot_to(a_sector)
    if self.delivered_quantity > 0
      if self.sector_supply_lot.present?
        @sector_supply_lot = SectorSupplyLot.where(
          sector_id: a_sector.id,
          supply_lot_id: self.sector_supply_lot.supply_lot_id
        ).first_or_create
        @sector_supply_lot.increment(self.delivered_quantity)
        @sector_supply_lot.save!
        self.entregado!
      else
        self.sin_stock!
      end
    end 
  end

  def increment_new_lot_to(a_sector)
    if self.lot_code.present? && self.laboratory_id.present?
      @supply_lot = SupplyLot.where(
        supply_id: self.supply_id,
        lot_code: self.lot_code,
        laboratory_id: self.laboratory_id,
      ).first_or_initialize
      @supply_lot.expiry_date = self.expiry_date
      @supply_lot.date_received = DateTime.now
      @supply_lot.save!
      @sector_supply_lot = SectorSupplyLot.where(
        sector_id: a_sector.id,
        supply_lot_id: @supply_lot.id
      ).first_or_create
      @sector_supply_lot.increment(self.delivered_quantity)
      @sector_supply_lot.save!
      self.entregado!
    else
      raise ArgumentError, 'El insumo '+self.supply_name+' no tiene lote asignado.' 
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
    self.sin_entregar!
  end

  def supply_name
    self.supply.name
  end

  def sector_supply_laboratory
    self.sector_supply_lot.laboratory
  end

  # Retorna el código del insumo del lote
  def supply_code
    self.sector_supply_lot.code
  end

  def sector_supply_lot_code
    self.sector_supply_lot.lot_code
  end

  # Retorna fecha de expiración del lote
  def sector_supply_expiry_date
    self.sector_supply_lot.expiry_date
  end

  # Retorna el tipo de unidad
  def unity
    self.supply.unity
  end

  def delivered_with_sector?(a_sector)
    self.quantifiable.delivered_with_sector?(a_sector)
  end
  
  def with_supply_code?(a_code)
    return self.supply.id == a_code
  end
  
  def self.orders_to(a_sector, a_code)
    QuantityOrdSupplyLot.where.not(quantifiable: nil)
      .where(supply_id: a_code)
      .includes(:quantifiable)
      .select { |qosl| qosl.delivered_with_sector?(a_sector) }
  end
end
