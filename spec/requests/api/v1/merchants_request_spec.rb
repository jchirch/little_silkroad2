require 'rails_helper'

RSpec.describe 'Merchant Endpoints' do
  before (:each) do
    @macho_man = Merchant.create!(name: "Randy Savage")
    @kozey_group = Merchant.create!(name: "Kozey Group")
    @real_human1 = Customer.create!(first_name: 'Ross', last_name: 'Ulbricht')
    @real_human2 = Customer.create!(first_name: 'Jack', last_name: 'Parsons')
    @illicit_goods = Item.create!(name: 'Contraband', description: 'Good Stuff', unit_price: 10.99, merchant_id: @macho_man.id)
    @cursed_object = Item.create!(name: 'Annabelle', description: 'Haunted Doll', unit_price: 6.66, merchant_id: @macho_man.id)
    @invoice1 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @macho_man.id, status: 'shipped')
    @invoice2 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'returned')   
  end
  describe 'HTTP Methods' do
    it 'Can return all merchants' do
      get "/api/v1/merchants"
      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      merchants.each do |merchant|

        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(String)

        expect(merchant).to have_key(:type)
        expect(merchant[:type]).to eq("merchant")

        merchant = merchant[:attributes]

        expect(merchant).to have_key(:name)
        expect(merchant[:name]).to be_a(String)
      end
    end

    it 'Can return one merchant' do
      get "/api/v1/merchants/#{@macho_man.id}"
      expect(response).to be_successful
      merchant = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)

      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to eq("merchant")

      merchant = merchant[:attributes]

      expect(merchant).to have_key(:name)
      expect(merchant[:name]).to be_a(String)
    end
  end

  describe 'return customers by merchant id' do
    it 'Can return all customers for a given merchant' do
      get "/api/v1/merchants/#{@macho_man.id}/customers"
      expect(response).to be_successful
      customers = JSON.parse(response.body, symbolize_names: true)[:data]
      customer1 = customers.find {|customer| customer[:id] == @real_human1.id.to_s}
      customer2 = customers.find {|customer| customer[:id] == @real_human2.id.to_s}

      expect(customers).to be_an(Array)
      expect(customers.count).to eq(2)
      expect(customer1).to have_key(:type)
      expect(customer1[:type]).to eq('customer')

      expect(customer1[:attributes]).to have_key(:first_name)
      expect(customer1[:attributes][:first_name]).to eq(@real_human1.first_name)
      expect(customer1[:attributes]).to have_key(:last_name)
      expect(customer1[:attributes][:last_name]).to eq(@real_human1.last_name)

      expect(customers).to eq([customer1, customer2])
    end

    it 'Returns empty array for customerless merchant' do
      really_bad_salesman = Merchant.create!(name: 'Arthur Miller')

      get "/api/v1/merchants/#{really_bad_salesman.id}/customers"
      expect(response).to be_successful
      customers = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(customers).to eq([])
    end
  end
end