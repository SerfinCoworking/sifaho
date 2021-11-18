require 'rails_helper'

# Test suite for User model
RSpec.describe User, type: :model do

  it 'does not create' do
    user = User.new
    expect(user.save).to be false
  end

  # Validation tests
  it { should validate_presence_of(:username) }
end