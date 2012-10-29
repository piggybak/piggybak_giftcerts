module PiggybakGiftcerts
  module LineItemDecorator
    extend ActiveSupport::Concern

    def preprocess_giftcert_application
      self.description = "Giftcert"
      self.giftcert_application.order = self.order
      if !self.new_record?
        valid_giftcert = ::PiggybakGiftcerts::Giftcert.valid_giftcert(self.giftcert_application.giftcert.code, self.order)
        if !valid_giftcert.is_a?(::PiggybakGiftcerts::Giftcert)
          self.mark_for_destruction
        end
      end
    end

    def postprocess_giftcert_application
      self.price = ::PiggybakGiftcerts::Giftcert.apply_giftcert(self.giftcert_application.giftcert.code, self.order, nil)
      true
    end 
  end
end
