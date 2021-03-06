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
        config.manage_classes << "::PiggybakGiftcerts::Giftcert"
        config.extra_abilities << { :abilities => [:read, :edit], :class_name => "::PiggybakGiftcerts::BuyableGiftcert" }
        config.extra_secure_paths << "/apply_giftcert"
        config.line_item_types[:giftcert_application] = { :visible => true,
                                                        :nested_attrs => true,
                                                        :fields => ["giftcert_application"],
                                                        :allow_destroy => true,
                                                        :class_name => "::PiggybakGiftcerts::GiftcertApplication",
                                                        :display_in_cart => "Gift Certificate",
                                                        :sort => config.line_item_types[:payment][:sort]
                                                      }
        config.line_item_types[:payment][:sort] += 1
        config.additional_line_item_attributes[:giftcert_application_attributes] = [:code]
      end
    end

    initializer "piggybak_variants.add_helper" do |app|
      ApplicationController.class_eval do
        helper :piggybak_variants
      end
    end

    initializer "piggybak_giftcerts.assets.precompile" do |app|
      app.config.assets.precompile += ['piggybak_giftcerts/piggybak_coupons.js']
    end

    initializer "piggybak_giftcerts.rails_admin_config" do |app|
      RailsAdmin.config do |config|
        config.model PiggybakGiftcerts::BuyableGiftcert do
          navigation_label "Extensions"
          label "Gift Certificate Configuration"
          list do
            # Hide filter, search, etc
            field :variants
          end
        end

        config.model PiggybakGiftcerts::Giftcert do
          navigation_label "Extensions"
          label "Gift Certificates"

          list do
            field :code
            field :amount do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :expiration_date
            field :order do
              label "Purchasing Order"
            end
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
