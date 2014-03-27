PiggybakGiftcerts::Engine.routes.draw do
  get "/apply_giftcert" => "giftcert#apply"
  get "/giftcert" => "giftcert#purchase", :as => "buy_giftcert"
end
