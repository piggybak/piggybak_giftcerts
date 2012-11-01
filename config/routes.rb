PiggybakGiftcerts::Engine.routes.draw do
  match "/apply_giftcert" => "giftcert#apply"
  match "/giftcert" => "giftcert#purchase"
end
