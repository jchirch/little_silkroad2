class Api::V1::InvoicesController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    invoices = merchant.invoices
    render json: InvoiceSerializer.new(invoices)
  end

  # def index
  #   merchant = Merchant.find(params[:merchant_id])
  #   render json: InvoiceSerializer.new(merchant.invoices)
  # end

end