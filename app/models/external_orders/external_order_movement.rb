class ExternalOrderMovement < ApplicationRecord
  include PgSearch::Model

  # Relationships
  belongs_to :user
  belongs_to :external_order
  belongs_to :sector

  # Scopes
  scope :by_action, ->(action_string) { where('action LIKE ?', action_string) }

  pg_search_scope :search_action,
                  against: :action,
                  ignoring: :accents # Ignorar tildes.
end
