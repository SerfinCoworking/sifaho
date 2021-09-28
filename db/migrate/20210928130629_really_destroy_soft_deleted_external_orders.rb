class ReallyDestroySoftDeletedExternalOrders < ActiveRecord::Migration[5.2]
  def change
    ExternalOrder.only_deleted.each(&:really_destroy!)
  end
end
