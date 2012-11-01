module PiggybakGiftcerts
  class GiftcertMailer < ActionMailer::Base
    default :from => Piggybak.config.email_sender,
            :cc => Piggybak.config.order_cc

    def info(order)
      @order = order

      mail(:to => order.email,
           :subject => "Order ##{order.id} Gift Certificates")
    end 
  end
end
