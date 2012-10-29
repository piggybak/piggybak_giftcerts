module PiggybakGiftcerts
  class Giftcert < ActiveRecord::Base
    self.table_name = 'giftcerts'

    has_many :giftcert_applications

    attr_accessor :application_detail
    attr_accessible :code, :amount, :expiration_date, :order_id

    validates_presence_of :code, :amount, :expiration_date
    validates_uniqueness_of :code
    validates_numericality_of :amount, :greater_than_or_equal_to => 0

    def remaining_balance
      self.amount + self.giftcert_applications.inject(0) { |applied, ga| applied + ga.line_item.price }
    end

    def application_detail
      "#{"$%.2f" % self.remaining_balance} of #{"$%.2f" % self.amount} remains."
    end

    def self.valid_giftcert(code, object)
      # First check
      giftcert = Giftcert.find_by_code(code)
      return "Invalid giftcert code." if giftcert.nil?

      # Expiration date check
      return "Expired giftcert." if giftcert.expiration_date < Date.today

      # Allowed applications check 
      return "This gift certificate has already been used." if giftcert.remaining_balance == 0

      giftcert
    end

    def self.apply_giftcert(code, object, totalcost = 0)
      giftcert = Giftcert.find_by_code(code)

      if object.is_a?(::Piggybak::Order)
        # Apply gift cert to everything exception payment and giftcert application
        totalcost = 0
        object.line_items.each do |line_item|
          if !['payment', 'giftcert_application'].include?(line_item.line_item_type)
            totalcost += line_item.price
          end
        end
      end

      if giftcert.remaining_balance > totalcost.to_f
        return -1*totalcost.to_f
      else
        return -1*giftcert.remaining_balance
      end
    end
  end
end
