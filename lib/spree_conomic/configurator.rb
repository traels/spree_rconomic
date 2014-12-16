module SpreeConomic
  class Configurator
    class << self
      attr_accessor :app_id, :app_token, :transfer_on_ship
      attr_reader :layout_handle, :term_of_payment_handle, :product_group_handle, :debtor_group_handle, :debtor_number, :vat_number, :shipping_product_number, :discount_product_number

      def config &block
        block.call(self)
      end

      # Proc will be called with a order
      def layout_handle=(handle)
        @layout_handle = wrap_in_proc(handle)
      end

      def term_of_payment_handle=(handle)
        @term_of_payment_handle = wrap_in_proc(handle)
      end

      # Proc will be called with a user
      def debtor_group_handle=(handle)
        @debtor_group_handle = wrap_in_proc(handle)
      end

      def debtor_number=(number)
        @debtor_number = wrap_in_proc(number)
      end

      def vat_number=(number)
        @vat_number = wrap_in_proc(number)
      end

      # Proc will be called with a variant
      def product_group_handle=(handle)
        @product_group_handle = wrap_in_proc(handle)
      end

      # Proc will be called with first shipping_method
      def shipping_product_number=(number)
        @shipping_product_number = wrap_in_proc(number)
      end

      # Proc will be called with label of adjustment
      def discount_product_number=(number)
        @discount_product_number = wrap_in_proc(number)
      end

      def wrap_in_proc(value)
        value.class == Proc ? value : ->(_) { value }
      end
    end
  end
end
