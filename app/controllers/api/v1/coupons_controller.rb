class Api::V1::CouponsController < ApplicationController

  def index
    if params[:sort_by_active] == "true"
      coupons = Coupon.sort_by_active(true)
    elsif params[:sort_by_active] == "false"
      coupons = Coupon.sort_by_active(false)
    else
      coupons = Merchant.find(params[:merchant_id]).coupons
    end
    render json: CouponSerializer.new(coupons)
  rescue ActiveRecord::RecordNotFound => error
    render json: ErrorSerializer.format_error(error, 404), status: :not_found
  end

  def show
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])
    render json: CouponSerializer.new(coupon, meta: {status: response.status}, params: {include_usage: params[:include_usage]})
  rescue ActiveRecord::RecordNotFound => error
    render json: ErrorSerializer.format_error(error, 404), status: :not_found
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.new(coupon_params)
    if coupon.save
      render json: CouponSerializer.new(coupon, meta: {status: response.status})
    else
      render json: { errors: coupon.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    coupon = Coupon.find(params[:id])
    if coupon.update(coupon_params)
      render json: CouponSerializer.new(coupon, meta: {status: response.status})#, status: :ok
    else
      render json: { errors: coupon.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_type, :value, :merchant_id, :active)
  end
end