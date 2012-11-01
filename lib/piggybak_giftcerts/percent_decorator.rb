module PiggybakGiftcerts
  module PercentDecorator
    extend ActiveSupport::Concern

    included do
      def self.rate(method, object)
        taxable_total = 0
        if object.is_a?(::Piggybak::Cart)
          object.sellables.each do |i|
            next if (i[:sellable].item.is_a?(::PiggybakVariants::Variant) && i[:sellable].item.item_type == "PiggybakGiftcerts::BuyableGiftcert")
            taxable_total += i[:quantity]*i[:sellable].price
          end
        else
          object.line_items.sellables.each do |li|
            next if (li.sellable.item.is_a?(::PiggybakVariants::Variant) && li.sellable.item.item_type == "PiggybakGiftcerts::BuyableGiftcert")
            taxable_total += li.quantity*li.sellable.price
          end
        end
        (method.metadata.detect { |m| m.key == "rate" }.value.to_f * taxable_total).to_c
      end
    end
  end
end
