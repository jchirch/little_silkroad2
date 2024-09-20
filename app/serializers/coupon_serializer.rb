class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :discount_type, :value, :merchant_id, :active
end