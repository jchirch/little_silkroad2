class Api::V1::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    coupons = Coupon.all
    render json: CouponSerializer.new(coupons)
  end

  def show
    coupon = Coupon.find(params[:id])
    # use_counter = coupon.invoices.count
    render json: CouponSerializer.new(coupon, {params: {include_usage: params[:include_usage]}})
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    # require 'pry'; binding.pry
    coupon = merchant.coupons.new(coupon_params)
    # coupon = Coupon.create(coupon_params)
    if coupon.save
      render json: CouponSerializer.new(coupon), status: :created
    else
      render json: { errors: coupon.errors[:code] }, status: :unprocessable_entity
    end
  end

  def update
    # begin
      coupon = Coupon.find(params[:id])
      if coupon.update(coupon_params)
        render json: CouponSerializer.new(coupon), status: :ok
      else
        render json: { errors: coupon.errors[:code] }, status: :unprocessable_entity
      end
    # end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_type, :value, :merchant_id, :active)
  end
end