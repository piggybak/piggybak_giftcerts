require 'piggybak_giftcerts/line_item_decorator'

module PiggybakGiftcerts
  class Engine < ::Rails::Engine
    isolate_namespace PiggybakGiftcerts

    config.to_prepare do
      Piggybak::LineItem.send(:include, ::PiggybakGiftcerts::LineItemDecorator)
    end

    config.before_initialize do
      Piggybak.config do |config|
        config.line_item_types[:giftcert_application] = { :visible => true,
                                                        :nested_attrs => true,
                                                        :fields => ["giftcert_application"],
                                                        :allow_destroy => true,
                                                        :class_name => "::PiggybakGiftcerts::GiftcertApplication",
                                                        :display_in_cart => "Discount"
                                                      } 
      end
    end

    initializer "piggybak_giftcerts.precompile_hook" do |app|
      app.config.assets.precompile += ['piggybak_giftcerts/piggybak_giftcerts.js']
    end

    initializer "piggybak_giftcerts.rails_admin_config" do |app|
      RailsAdmin.config do |config|
      end
    end 
  end
end
