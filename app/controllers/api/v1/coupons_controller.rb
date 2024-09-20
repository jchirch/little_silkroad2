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

  end

  def update

  end
end