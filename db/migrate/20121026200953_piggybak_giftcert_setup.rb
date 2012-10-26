class PiggybakGiftcertSetup < ActiveRecord::Migration
  def up
    create_table :giftcerts do |t|
      t.string :code, :null => false
      t.decimal :amount, :null => false
      t.date :expiration_date
      t.references :order
    end
    create_table :giftcert_applications do |t|
      t.references :line_item
      t.references :giftcert
    end
  end

  def down
    drop_table :giftcerts    
    drop_table :giftcert_applications
  end
end
