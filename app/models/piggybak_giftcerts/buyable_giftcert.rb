module PiggybakGiftcerts
  class BuyableGiftcert < ActiveRecord::Base
    self.table_name = 'buyable_giftcerts'

    acts_as_sellable_with_variants

    validate :only_one
    def only_one
      if ::PiggybakGiftcerts::BuyableGiftcert.count > 0 && self.new_record?
        self.errors.add(:base, "You may only have one buyable gift certificate.")
      end
    end
  end
end
