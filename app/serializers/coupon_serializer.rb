class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :discount_type, :value, :merchant_id, :active
  attribute :use_counter, if: Proc.new {|coupon, params| params[:include_usage] == 'true' } do |coupon|
    coupon.invoices.count
  end
end