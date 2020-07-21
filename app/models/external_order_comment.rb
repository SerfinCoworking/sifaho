class ExternalOrderComment < ApplicationRecord
  belongs_to :external_order
  belongs_to :user

  def provider_sector?(a_user)
    self.external_order.provider_sector == a_user.sector
  end
end
