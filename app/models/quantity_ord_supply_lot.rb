class QuantityOrdSupplyLot < ApplicationRecord
  enum status: { sin_entregar: 0, entregado: 1, sin_stock: 2 }

  # Relaciones
  belongs_to :supply, -> { with_deleted }
  belongs_to :laboratory, optional: true
  belongs_to :cronic_dispensation, optional: true
  belongs_to :sector_supply_lot, -> { with_deleted }, optional: true
  belongs_to :supply_lot, -> { with_deleted }, optional: true
  belongs_to :quantifiable, :polymorphic => true
  has_one :sector, :through => :sector_supply_lot

  # Validaciones
  validates_presence_of :supply, :requested_quantity, :delivered_quantity
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

  # Delegaciones
  delegate :unity, to: :supply
  delegate :name, to: :supply, prefix: :supply
  delegate :code, to: :sector_supply_lot, prefix: :supply
  delegate :laboratory, to: :sector_supply_lot, prefix: :sector_supply


  scope :agency_referrals, -> (id, city_town) { includes(client: :address).where(agency_id: id, 'client.address.city_town' => city_town) }
  scope :to_sector, lambda { |a_sector| joins(:sector_supply_lot).where(sector_supply_lots: { sector: a_sector }) }

  scope :dispensed_since, lambda { |a_date| where('quantity_ord_supply_lots.dispensed_at >= ?', a_date) }
  scope :dispensed_to, lambda { |a_date| where('quantity_ord_supply_lots.dispensed_at <= ?', a_date ) }

  # Métodos públicos
  def increment_lot_to(a_sector)
    if self.delivered_quantity > 0
      if self.sector_supply_lot.present?
        @sector_supply_lot = SectorSupplyLot.where(
          sector_id: a_sector.id,
          supply_lot_id: self.sector_supply_lot.supply_lot_id
        ).first_or_create
        @sector_supply_lot.increment(self.delivered_quantity)
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
      self.entregado!
    else
      raise ArgumentError, 'El insumo '+self.supply_name+' no tiene lote asignado.' 
    end
  end

  def decrement
    if self.sector_supply_lot.present?
      self.sector_supply_lot.decrement(self.delivered_quantity)
    end
    self.entregado!
  end

  def decrement_to_cronic(cronic_dispensation)
    if self.sector_supply_lot.present?
      if self.sector_supply_lot.decrement(self.delivered_quantity)
        new_qosl = self.dup
        new_qosl.save!
        self.cronic_dispensation = cronic_dispensation
        self.entregado!
      end
    else
      cronic_dispensation.destroy
      raise ArgumentError, 'No hay lote asignado para '+self.supply_name
    end
  end

  def increment
    if self.sector_supply_lot.present?
      self.sector_supply_lot.increment(self.delivered_quantity)
    end
    self.sin_entregar!
  end

  def sector_supply_lot_lot_code
    if self.sector_supply_lot.present?  
      self.sector_supply_lot.lot_code
    elsif self.lot_code.present?
      self.lot_code
    else
      'n/a'
    end
  end

  # Retorna fecha de expiración del lote
  def sector_supply_lot_expiry_date
    if self.sector_supply_lot.present?
      self.sector_supply_lot.format_expiry_date
    elsif self.expiry_date.present?
      self.expiry_date.strftime('%m/%y')
    elsif self.lot_code.present?
      'No vence'
    else 
      'n/a'  
    end
  end

  def sector_supply_lot_laboratory_name
    if self.sector_supply_lot.present?
      self.sector_supply_lot.laboratory
    elsif self.laboratory.present?
      self.laboratory.name
    else
      'n/a'
    end
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
