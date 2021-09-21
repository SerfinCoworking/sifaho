class DestroyOrderProdLotStocksFromAuditingProviders < ActiveRecord::Migration[5.2]
  def change
    # Iterate through all 'proveedor auditoria' external and internal order and destroy the ord_prod_lot_stock relationships
    ExternalOrder.proveedor_auditoria.find_each do |order|
      order.ext_ord_prod_lot_stocks.find_each(&:destroy!)
    end

    InternalOrder.proveedor_auditoria.find_each do |order|
      order.int_ord_prod_lot_stocks.find_each(&:destroy!)
    end
  end
end
