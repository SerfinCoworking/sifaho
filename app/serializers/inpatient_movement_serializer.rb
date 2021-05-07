class InpatientMovementSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_one :bed
  has_one :patient
  has_one :movement_type
  has_one :user
end
