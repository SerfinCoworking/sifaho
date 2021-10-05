class MoveObservationsToProviderObservationsExternalOrderTemplates < ActiveRecord::Migration[5.2]
  def change
    ex_order_provider_templates = ExternalOrderTemplate.where(order_type: :provision)
    ex_order_provider_templates.each do |provider|
      observation = provider.observation
      provider.update_columns(provider_observation: observation, observation: '')
    end
  end
end
