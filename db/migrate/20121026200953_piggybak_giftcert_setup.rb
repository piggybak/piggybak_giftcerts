class PiggybakGiftcertSetup < ActiveRecord::Migration
  def up
    create_table :giftcerts do |t|
      t.string :code, :null => false
      t.decimal :amount, :null => false
      t.date :expiration_date
      t.references :order
      t.timestamps
    end
    create_table :buyable_giftcerts do |t|
    end
    create_table :giftcert_applications do |t|
      t.references :line_item
      t.references :giftcert
      t.timestamps
    end

    ::PiggybakGiftcerts::BuyableGiftcert.create()
  end

  def down
    drop_table :giftcerts
    drop_table :buyable_giftcerts
    drop_table :giftcert_applications
  end
end
