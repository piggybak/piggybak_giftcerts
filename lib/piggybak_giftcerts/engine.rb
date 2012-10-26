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
        config.model PiggybakGiftcerts::Giftcert do
          navigation_label "Orders"
          label "Gift Certificates"

          list do
            field :code
            field :amount
            field :expiration_date
            # application details -> show how much used
          end
          edit do
            field :code
            field :amount
            field :expiration_date
          end
        end

        config.model PiggybakGiftcerts::GiftcertApplication do
          label "Giftcert"
          visible false

          edit do
            field :code do
              read_only do
                !bindings[:object].new_record?
              end
              pretty_value do
                bindings[:object].giftcert ? bindings[:object].giftcert.code : ""
              end 
            end
          end
        end
      end
    end 
  end
end
