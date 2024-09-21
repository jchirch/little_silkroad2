class Api::V1::CouponsController < ApplicationController

  def index
    coupons = Coupon.all
    render json: CouponSerializer.new(coupons)
  end

  def show
    coupon = Coupon.find(params[:id])
    render json: CouponSerializer.new(coupon, meta: {status: response.status}, params: {include_usage: params[:include_usage]})
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.new(coupon_params)
    if coupon.save
      render json: CouponSerializer.new(coupon, meta: {status: response.status})
    else
      render json: { errors: coupon.errors[:code] }, status: :unprocessable_entity
    end
  end

  def update
    coupon = Coupon.find(params[:id])
    if coupon.update(coupon_params)
      render json: CouponSerializer.new(coupon, meta: {status: response.status})#, status: :ok
    else
      render json: { errors: coupon.errors[:code] }#, status: :unprocessable_entity
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_type, :value, :merchant_id, :active)
  end
end