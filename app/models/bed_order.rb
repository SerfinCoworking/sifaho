class BedOrder < ApplicationRecord
  belongs_to :bedroom
  belongs_to :patient
  belongs_to :audited_by, class_name: 'User', optional: true
  belongs_to :sent_by, class_name: 'User', optional: true
  belongs_to :received_by, class_name: 'User', optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :sent_request_by, class_name: 'User', optional: true
end
