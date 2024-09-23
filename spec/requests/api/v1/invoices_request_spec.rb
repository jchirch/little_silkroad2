require 'rails_helper'

RSpec.describe 'Invoice Endpoints:' do
  before(:each) do
    @merchant1 = Merchant.create(name: "Example 1")
    @customer1 = Customer.create(first_name: 'Mr', last_name: 'Customer')
    @coupon1 = Coupon.create(name: 'Hello Offer', code: 'TAKESOME10', discount_type: 'percent', value: 10, merchant: @merchant1, active: true)
    @coupon2 = Coupon.create(name: 'Equinox Special', code: 'SUNNY20', discount_type: 'percent', value: 20, merchant: @merchant1, active: true)
    @invoice1 = Invoice.create(customer: @customer1, merchant: @merchant1, status: 'shipped', coupon: @coupon1)
    @invoice2 = Invoice.create(customer: @customer1, merchant: @merchant1, status: 'returned', coupon: @coupon2)   
    @invoice3 = Invoice.create(customer: @customer1, merchant: @merchant1, status: 'returned', coupon: nil)   
  end

  describe 'Access coupon id through merchant invoices' do
    it 'returns coupon id through merchant invoice' do
      get "/api/v1/merchants/#{@merchant1.id}/invoices"

      expect(response).to be_successful
      invoices = JSON.parse(response.body, symbolize_names: true)[:data]
    
      expect(invoices[0][:attributes][:coupon_id]).to eq(@coupon1.id)
      expect(invoices[1][:attributes][:coupon_id]).to eq(@coupon2.id)
      expect(invoices[2][:attributes][:coupon_id]).to be_nil
    end
  end
end