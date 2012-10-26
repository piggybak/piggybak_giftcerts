module PiggybakGiftcerts
  class Giftcert < ActiveRecord::Base
    self.table_name = 'giftcerts'

    has_many :giftcert_applications

    attr_accessible :code, :amount, :expiration_date, :order_id

    validates_presence_of :code, :amount, :expiration_date
    validates_uniqueness_of :code
    validates_numericality_of :amount, :greater_than_or_equal_to => 0

    def remaining_balance
      self.amount - self.giftcert_applications.inject(0) { |applied, ga| applied + ga.line_item.total }
    end

    def self.valid_giftcert(code, object)
      # First check
      giftcert = Giftcert.find_by_code(code)
      return "Invalid giftcert code." if giftcert.nil?

      # Expiration date check
      return "Expired giftcert." if giftcert.expiration_date < Date.today

      # Allowed applications check 
      return "Giftcert has already been used." if giftcert.remaining_balance == 0

      giftcert
    end

    def self.apply_giftcert(code, object, shipcost = 0.0)
      # if giftcert.remaining_balance > total order cost
        # return total order cost
      # else
        # return remaining balance 
      return 0 
    end
  end
end
