require 'piggybak_giftcerts/line_item_decorator'
require 'piggybak_giftcerts/order_decorator'
require 'piggybak_giftcerts/percent_decorator'

module PiggybakGiftcerts
  class Engine < ::Rails::Engine
    isolate_namespace PiggybakGiftcerts

    config.to_prepare do
      Piggybak::LineItem.send(:include, ::PiggybakGiftcerts::LineItemDecorator)
      Piggybak::Order.send(:include, ::PiggybakGiftcerts::OrderDecorator)
      Piggybak::TaxCalculator::Percent.send(:include, ::PiggybakGiftcerts::PercentDecorator)
    end

    config.before_initialize do
      Piggybak.config do |config|
        config.line_item_types[:giftcert_application] = { :visible => true,
                                                        :nested_attrs => true,
                                                        :fields => ["giftcert_application"],
                                                        :allow_destroy => true,
                                                        :class_name => "::PiggybakGiftcerts::GiftcertApplication",
                                                        :display_in_cart => "Gift Certificate",
                                                        :sort => config.line_item_types[:payment][:sort]
                                                      }
        config.line_item_types[:payment][:sort] += 1
      end
    end

    initializer "piggybak_variants.add_helper" do |app|
      ApplicationController.class_eval do
        helper :piggybak_variants
      end
    end

    initializer "piggybak_giftcerts.precompile_hook" do |app|
      app.config.assets.precompile += ['piggybak_giftcerts/piggybak_giftcerts.js']
    end

    initializer "piggybak_giftcerts.rails_admin_config" do |app|
      RailsAdmin.config do |config|
        config.model PiggybakGiftcerts::BuyableGiftcert do
          navigation_label "Orders"
          label "Gift Certificate Configuration"
          list do
            # Hide filter, search, etc
            field :variants
          end
        end

        config.model PiggybakGiftcerts::Giftcert do
          navigation_label "Orders"
          label "Gift Certificates"

          list do
            field :code
            field :amount do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :expiration_date
            field :application_detail
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
