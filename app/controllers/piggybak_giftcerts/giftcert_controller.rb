module PiggybakGiftcerts
  class GiftcertController < ApplicationController
    def apply
      cart = Piggybak::Cart.new(request.cookies["cart"])
      valid_giftcert = ::PiggybakGiftcerts::Giftcert.valid_giftcert(params[:code], cart)
      if valid_giftcert.is_a?(::PiggybakGiftcerts::Giftcert)
        amount = ::PiggybakGiftcerts::Giftcert.apply_giftcert(params[:code], cart, params[:totalcost])
        render :json => { :valid_giftcert => true, :amount => amount }
      else
        render :json => { :valid_giftcert => false, :message => valid_giftcert }
      end
    end

    def purchase
      @buyable_giftcert = BuyableGiftcert.first
    end
  end
end
