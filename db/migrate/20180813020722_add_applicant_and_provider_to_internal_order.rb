class AddApplicantAndProviderToInternalOrder < ActiveRecord::Migration[5.1]
  def change
    add_reference :internal_orders, :provider, index: true
    add_reference :internal_orders, :applicant, index: true
  end
end
