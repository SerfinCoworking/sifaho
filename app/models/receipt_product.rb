class ReceiptProduct < ApplicationRecord
  belongs_to :receipt
  belongs_to :laboratory
  belongs_to :supply, -> { with_deleted }
  belongs_to :supply_lot, -> { with_deleted }, optional: true
  belongs_to :sector_supply_lot, -> { with_deleted }, optional: true

  # Validaciones
  validates_presence_of :receipt, :supply_id, :lot_code, :laboratory_id


  def increment_new_lot_to(a_sector)
      @supply_lot = SupplyLot.where(
        supply_id: self.supply_id,
        lot_code: self.lot_code,
        laboratory_id: self.laboratory_id,
      ).first_or_initialize
      @supply_lot.expiry_date = self.expiry_date
      @supply_lot.save!
      @sector_supply_lot = SectorSupplyLot.where(
        sector_id: a_sector.id,
        supply_lot_id: @supply_lot.id
      ).first_or_create
      @sector_supply_lot.increment(self.quantity)
  end

end

