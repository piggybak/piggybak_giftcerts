module PiggybakGiftcerts
  module OrderDecorator
    extend ActiveSupport::Concern

    included do
      alias :piggybak_create_payment_shipment :create_payment_shipment
      def create_payment_shipment; giftcert_create_payment_shipment; end

      after_create :create_and_send_giftcert_email, :if => Proc.new { |order| order.user_agent != "admin" }

      has_many :giftcerts, :class_name => "::PiggybakGiftcerts::Giftcert"
    end

    def giftcert_create_payment_shipment
      piggybak_create_payment_shipment

      # Deleting Piggybak line item if gift certificate coverage 
      payment_line_item = self.line_items.detect { |li| li.line_item_type == "payment" }
      if payment_line_item && payment_line_item.payment.number == "giftcert"
        self.line_items.delete(payment_line_item)
      end
    end

    def create_and_send_giftcert_email
      begin
        self.line_items.sellables.each do |li| 
          next if !(li.sellable.item.is_a?(::PiggybakVariants::Variant) && li.sellable.item.item_type == "PiggybakGiftcerts::BuyableGiftcert")
          li.quantity.times do
            # TODO: Replace 2.years with configurable interval
            gc = ::PiggybakGiftcerts::Giftcert.new({ :amount => li.unit_price, :order_id => self.id, :expiration_date => Date.today + 2.years })
            if !gc.save
              Rails.logger.warn "Could not create gift certificate: #{gc.errors.full_messages}"
            end
          end
        end
        ::PiggybakGiftcerts::GiftcertMailer.info(self).deliver
      rescue
      end
    end 
  end
end
