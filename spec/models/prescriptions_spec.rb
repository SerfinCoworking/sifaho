require 'rails_helper'

# Test suite for the Prescription model
RSpec.describe Prescription, type: :model do
  # Association test
  # ensure an Prescription record belongs to a single patient and professional record
  it { should belong_to(:patient) }
  it { should belong_to(:professional) }
  it { should have_many(:quantity_ord_supply_lots) }
  # Validation test
  # ensure column name is present before saving
  it { should validate_presence_of(:prescribed_date) }
  it { should validate_presence_of(:remit_code) }
end