require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoices) }
  end

  describe 'validations' do
    it {should validate_uniqueness_of(:code).with_message("This coupon code already exists")}
  end
end