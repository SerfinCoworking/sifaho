class PermissionRequestSerializer < ActiveModel::Serializer
  attributes :id, :status, :observation
  has_one :user
end
