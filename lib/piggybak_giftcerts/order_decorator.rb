module PiggybakGiftcerts
  module OrderDecorator
    extend ActiveSupport::Concern

    included do
      alias :piggybak_create_payment_shipment :create_payment_shipment
      def create_payment_shipment; giftcert_create_payment_shipment; end
    end

    def giftcert_create_payment_shipment
      piggybak_create_payment_shipment

      # Deleting Piggybak line item if gift certificate coverage 
      payment_line_item = self.line_items.detect { |li| li.line_item_type == "payment" }
      if payment_line_item && payment_line_item.payment.number == "giftcert"
        self.line_items.delete(payment_line_item)
      end
    end 
  end
end
