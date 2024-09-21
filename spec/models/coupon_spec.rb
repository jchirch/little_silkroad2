require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoices) }
  end

  describe 'validations' do
    it {should validate_presence_of(:name).with_message("Name is required")}
    it {should validate_presence_of(:code).with_message("Code is required")}
    it {should validate_uniqueness_of(:code).with_message("This coupon code already exists")}
    it {should validate_presence_of(:discount_type).with_message("Must be 'dollar' or 'percent'")}
    it {should validate_presence_of(:active).with_message("Status is required")}
  end
end