require 'rails_helper'

# Test suite for the Patient model
RSpec.describe Patient, type: :model do
  # Association test
  # ensure Patient model has a 1:m relationship with the Prescription model
  it { should have_many(:prescriptions).dependent(:destroy) }
  # Validation tests
  # ensure columns title and created_by are present before saving
  it { should validate_presence_of(:dni) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
end