module PiggybakGiftcerts
  class GiftcertController < ApplicationController
    def apply
      cart = Piggybak::Cart.new(request.cookies["cart"])
      valid_giftcert = ::PiggybakGiftcerts::Giftcert.valid_giftcert(params[:code], cart, true)
      if valid_giftcert.is_a?(::PiggybakGiftcerts::Giftcert)
        amount = ::PiggybakGiftcerts::Giftcert.apply_discount(params[:code], cart, params[:shipcost])
        render :json => { :valid_giftcert => true, :amount => amount }
      else
        render :json => { :valid_giftcert => false, :message => valid_giftcert }
      end
    end
  end
end
