class Api::V1::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    coupons = Coupon.all
    render json: CouponSerializer.new(coupons)
  end

  def show
    coupon = Coupon.find(params[:id])
    render json: CouponSerializer.new(coupon)
  end

  def create
    coupon = Coupon.create(coupon_params)
    render json: CouponSerializer.new(coupon)
  end

  def update
    begin
      coupon = Coupon.find(params[:id])
      if coupon.update(coupon_params)
        render json: CouponSerializer.new(coupon)
      end
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_type, :value, :merchant_id, :active)
  end
end