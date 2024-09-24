require 'rails_helper'

RSpec.describe 'Coupon Endpoints' do
  before (:each) do
    @macho_man = Merchant.create!(name: "Randy Savage")
    @kozey_group = Merchant.create!(name: "Kozey Group")
    @hot_topic = Merchant.create!(name: "Hot Topic")

    @coupon1 = Coupon.create!(name: 'Welcome Offer', code: 'TAKE10', discount_type: 'percent', value: 10, merchant_id: @macho_man.id, active: true)
    @coupon2 = Coupon.create!(name: 'Summer Special', code: 'SUNSHINE20', discount_type: 'percent', value: 20, merchant_id: @macho_man.id, active: true)
    @coupon3 = Coupon.create!(name: 'Holiday Sale', code: 'HOLIDAY50', discount_type: 'percent', value: 50, merchant_id: @macho_man.id, active: false)
    @coupon4 = Coupon.create!(name: 'Free Money', code: 'FREE20', discount_type: 'dollar', value: 20, merchant_id: @macho_man.id, active: true)
    @coupon5 = Coupon.create!(name: 'VIP Offer', code: 'VIP30', discount_type: 'dollar', value: 30, merchant_id: @macho_man.id, active: true)
    @coupon6 = Coupon.create!(name: 'Black Friday', code: 'BF40', discount_type: 'percent', value: 40, merchant_id: @macho_man.id, active: false)
  end

  describe 'HTTP Methods' do
    it 'Can return all coupons' do
      get "/api/v1/merchants/#{@macho_man.id}/coupons"

      expect(response).to be_successful

      coupons = JSON.parse(response.body, symbolize_names: true)[:data]

      coupons.each do |coupon|

        expect(coupon).to have_key(:id)
        expect(coupon[:id]).to be_a(String)

        expect(coupon).to have_key(:type)
        expect(coupon[:type]).to eq('coupon')

        coupon = coupon[:attributes]

        expect(coupon).to have_key(:name)
        expect(coupon[:name]).to be_a(String)

        expect(coupon).to have_key(:code)
        expect(coupon[:code]).to be_a(String)

        expect(coupon).to have_key(:discount_type)
        expect(coupon[:discount_type]).to be_a(String)

        expect(coupon).to have_key(:value)
        expect(coupon[:value]).to be_an(Integer)

        expect(coupon).to have_key(:merchant_id)
        expect(coupon[:merchant_id]).to be_a(Integer)

        expect(coupon).to have_key(:active)
        expect(coupon[:active]).to be_in([true, false])
      end
    end

    it 'Can return one coupon' do
      get "/api/v1/merchants/#{@macho_man.id}/coupons/#{@coupon2.id}"

      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)
      coupon = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(coupon[:id]).to eq(@coupon2.id.to_s)
      expect(response_body[:meta][:status]).to eq(200)

      coupon = coupon[:attributes]

      expect(coupon[:name]).to eq(@coupon2.name)
      expect(coupon[:code]).to eq(@coupon2.code)
      expect(coupon[:discount_type]).to eq(@coupon2.discount_type)
      expect(coupon[:value]).to eq(@coupon2.value)
      expect(coupon[:merchant_id]).to eq(@coupon2.merchant_id)
      expect(coupon[:active]).to eq(@coupon2.active)
    end

    it 'Can return one coupon with optional usage attrribute' do
      get "/api/v1/merchants/#{@macho_man.id}/coupons/#{@coupon3.id}?include_usage=true"
      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)
      coupon = JSON.parse(response.body, symbolize_names: true)[:data][:attributes]

      expect(coupon).to have_key(:use_counter)
      expect(coupon[:use_counter]).to be_an(Integer)
      expect(coupon[:use_counter]).to eq(@coupon3.invoices.count)
    end

    it 'Can create a coupon' do
      expect(Coupon.count).to eq(6)

      new_coupon_params = {name: 'Spooktacular Savings', code: '50Ween', discount_type: 'percent', value: 50, merchant_id: @hot_topic.id, active: true}

      post "/api/v1/merchants/#{@hot_topic.id}/coupons", params: {coupon: new_coupon_params}, as: :json

      expect(response).to be_successful
      expect(Coupon.count).to eq(7)
      new_coupon = Coupon.last
      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body[:meta][:status]).to eq(200)

      expect(new_coupon.name).to eq(new_coupon_params[:name])
      expect(new_coupon.code).to eq(new_coupon_params[:code])
      expect(new_coupon.discount_type).to eq(new_coupon_params[:discount_type])
      expect(new_coupon.value).to eq(new_coupon_params[:value])
      expect(new_coupon.merchant_id).to eq(new_coupon_params[:merchant_id])
      expect(new_coupon.active).to eq(new_coupon_params[:active])
    end

    it 'Can update active status attribute' do
      new_coupon_status_params = {active: false}
      expect(@coupon1.active).to be(true)

      patch "/api/v1/merchants/#{@macho_man.id}/coupons/#{@coupon1.id}", params: {coupon: new_coupon_status_params}, as: :json
      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)
      @coupon1.reload
      expect(response_body[:meta][:status]).to eq(200)
      expect(@coupon1.active).to be(false)
    end
  end

  describe '#sort_by_active' do
  it 'returns all active coupons for the specific merchant' do
    merchant = Merchant.create!(name: "Cozy Group")
    dud_coupon1 = Coupon.create!(name: 'Test Offer1', code: 'TAKE54', discount_type: 'percent', value: 10, merchant_id: merchant.id, active: false)
    dud_coupon2 = Coupon.create!(name: 'Test Offer2', code: 'TAKE53', discount_type: 'percent', value: 20, merchant_id: merchant.id, active: false)
    active_coupon = Coupon.create!(name: 'Test Offer Good', code: 'TAKE52', discount_type: 'percent', value: 60, merchant_id: merchant.id, active: true)

    active_coupons = Coupon.where(merchant_id: merchant.id).sort_by_active(true)
    expect(active_coupons).to eq([active_coupon])
  end

  it 'returns all inactive coupons for the specific merchant' do
    merchant = Merchant.create!(name: "Cozy Group")
    dud_coupon1 = Coupon.create!(name: 'Test Offer1', code: 'TAKE54', discount_type: 'percent', value: 10, merchant_id: merchant.id, active: false)
    dud_coupon2 = Coupon.create!(name: 'Test Offer2', code: 'TAKE53', discount_type: 'percent', value: 20, merchant_id: merchant.id, active: false)
    active_coupon = Coupon.create!(name: 'Test Offer Good', code: 'TAKE52', discount_type: 'percent', value: 60, merchant_id: merchant.id, active: true)

    inactive_coupons = Coupon.where(merchant_id: merchant.id).sort_by_active(false)
    expect(inactive_coupons).to eq([dud_coupon1, dud_coupon2])
  end

  it 'returns all coupons for the specific merchant if invalid parameters' do
    merchant = Merchant.create!(name: "Cozy Group")
    dud_coupon1 = Coupon.create!(name: 'Test Offer1', code: 'TAKE54', discount_type: 'percent', value: 10, merchant_id: merchant.id, active: false)
    dud_coupon2 = Coupon.create!(name: 'Test Offer2', code: 'TAKE53', discount_type: 'percent', value: 20, merchant_id: merchant.id, active: false)
    active_coupon = Coupon.create!(name: 'Test Offer Good', code: 'TAKE52', discount_type: 'percent', value: 60, merchant_id: merchant.id, active: true)

    coupons = Coupon.where(merchant_id: merchant.id).sort_by_active("idk")
    expect(coupons).to eq([dud_coupon1, dud_coupon2, active_coupon])
  end
end

  describe '#sort_by_active for index' do
    it 'Coupon.sort_by_active(true)' do
      get "/api/v1/merchants/#{@macho_man.id}/coupons?sort_by_active=true"

      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)
      result = JSON.parse(response.body, symbolize_names: true)[:data]
      expected= [
        {
          id: @coupon1.id.to_s, 
          type: 'coupon',       
          attributes: {
            name: @coupon1.name,
            code: @coupon1.code,
            discount_type: @coupon1.discount_type,
            value: @coupon1.value,
            merchant_id: @coupon1.merchant_id,
            active: @coupon1.active
          }
        },
        {
          id: @coupon2.id.to_s,
          type: 'coupon',
          attributes: {
            name: @coupon2.name,
            code: @coupon2.code,
            discount_type: @coupon2.discount_type,
            value: @coupon2.value,
            merchant_id: @coupon2.merchant_id,
            active: @coupon2.active
          }
        },
        {
          id: @coupon4.id.to_s,
          type: 'coupon',
          attributes: {
            name: @coupon4.name,
            code: @coupon4.code,
            discount_type: @coupon4.discount_type,
            value: @coupon4.value,
            merchant_id: @coupon4.merchant_id,
            active: @coupon4.active
          }
        },
        {
          id: @coupon5.id.to_s,
          type: 'coupon',
          attributes: {
            name: @coupon5.name,
            code: @coupon5.code,
            discount_type: @coupon5.discount_type,
            value: @coupon5.value,
            merchant_id: @coupon5.merchant_id,
            active: @coupon5.active
          }
        }
      ]
      expect(result).to eq(expected)
    end
    it 'Coupon.sort_by_active(false)' do
      get "/api/v1/merchants/#{@macho_man.id}/coupons?sort_by_active=false"

      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)
      result = JSON.parse(response.body, symbolize_names: true)[:data]

      expected = [
        {
          id: @coupon3.id.to_s, 
          type: 'coupon',       
          attributes: {
            name: @coupon3.name,
            code: @coupon3.code,
            discount_type: @coupon3.discount_type,
            value: @coupon3.value,
            merchant_id: @coupon3.merchant_id,
            active: @coupon3.active
          }
        },
        {
          id: @coupon6.id.to_s,
          type: 'coupon',
          attributes: {
            name: @coupon6.name,
            code: @coupon6.code,
            discount_type: @coupon6.discount_type,
            value: @coupon6.value,
            merchant_id: @coupon6.merchant_id,
            active: @coupon6.active
          }
        }
      ]
      expect(result).to eq(expected)
    end
  end

  describe 'Rescue blocks' do
    it 'returns error with incorrect search params for all merchants coupons' do
      get "/api/v1/merchants/0/coupons"
      expect(response).to_not be_successful
      error_response = JSON.parse(response.body)

      expect(error_response['message']).to eq("We could not complete your request, please enter new query.")
      expect(error_response['errors']).to eq(["Couldn't find Merchant with 'id'=0"])
    end

    it 'returns error with incorrect search params for one coupon' do
      get "/api/v1/merchants/0/coupons/0"
      expect(response).to_not be_successful
      error_response = JSON.parse(response.body)

      expect(error_response['message']).to eq("We could not complete your request, please enter new query.")
      expect(error_response['errors']).to eq(["Couldn't find Merchant with 'id'=0"])
    end
  end

  describe 'Sad paths' do
    it 'Can only create coupons with unique codes' do
      Coupon.create!(name: 'Initial Coupon', code: 'HOWDY10', discount_type: 'dollar', value: 10, merchant_id: @hot_topic.id, active: true)
      new_coupon_params = {name: 'Initial Coupon Clone', code: 'HOWDY10', discount_type: 'dollar', value: 10, merchant_id: @hot_topic.id, active: true}

      post "/api/v1/merchants/#{@hot_topic.id}/coupons", params: {coupon: new_coupon_params}, as: :json
      expect(response).to_not be_successful
      expect(response.status).to eq(422)
      data = JSON.parse(response.body, symbolize_names: true)
  
      expect(data[:errors]).to be_a(Array)
      expect(data[:errors]).to include("Code This coupon code already exists")
    end

    it 'renders error if patch fails from invalid data' do
      coupon = Coupon.create!(name: 'Change My Name', code: 'Test123', discount_type: 'percent', value: 20, merchant_id: @macho_man.id, active: true)
      new_coupon_status_params = {name: ""}
      patch "/api/v1/merchants/#{@macho_man.id}/coupons/#{coupon.id}", params: {coupon: new_coupon_status_params}, as: :json      # require 'pry'; binding.pry
      errors = (JSON.parse(response.body)["errors"])
     
      expect(response).to_not be_successful
      expect(response.status).to eq(422)
      expect(errors).to eq(["Name Name is required"])
    end

    it 'returns error if more than 5 active coupons exist for merchant' do
      fifth_coupon_params = {name: '5th active', code: 'ALMOST10', discount_type: 'dollar', value: 10, merchant_id: @macho_man.id, active: true}
      sixth_coupon_params = {name: '6th active', code: 'OHNO10', discount_type: 'dollar', value: 10, merchant_id: @macho_man.id, active: true}

      post "/api/v1/merchants/#{@macho_man.id}/coupons", params: {coupon: fifth_coupon_params}, as: :json
      post "/api/v1/merchants/#{@macho_man.id}/coupons", params: {coupon: sixth_coupon_params}, as: :json
      
      expect(response.status).to eq(422)
      expect(response).to have_http_status(:unprocessable_entity)
      error_response = JSON.parse(response.body)
      expect(error_response['errors']).to eq(["Merchant Merchant can only have a maximum of 5 active coupons at once."])
    end
  end
end