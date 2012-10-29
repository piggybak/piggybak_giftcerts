module PiggybakGiftcerts
  class GiftcertApplication < ActiveRecord::Base
    self.table_name = "giftcert_applications"

    belongs_to :giftcert
    belongs_to :line_item, :class_name => "::Piggybak::LineItem", :dependent => :destroy

    attr_accessor :code, :order
    attr_accessible :line_item_id, :gift_cert_id, :code

    validate :validate_giftcert
    def validate_giftcert
      if self.new_record?
        valid_giftcert = Giftcert.valid_giftcert(self.code, self.order)
        if valid_giftcert.is_a?(::PiggybakGiftcerts::Giftcert)
          self.giftcert_id = valid_giftcert.id
        else
          self.errors.add(:code, valid_giftcert)
        end
      end
    end
  end
end
