module SpreeConomic
  class OrderInvoicer
    def transfer(order)
      # create / update debtor
      debtor = upsert_debtor(order.user)

      # create products
      order.line_items.each do |line_item|
        upsert_product(line_item.variant)
      end

      # create invoice
      create_invoice(order, debtor)

      # rescue StandardError => e
      # delete invoice (if created)
    end

    private

    # Signs in to e-conomic with app_id and app_token from configuration
    #
    # @return [Economic::Session] logged into e-conomic
    def economic
      @economic ||= begin
        @economic = Economic::Session.new
        @economic.connect_with_token SpreeConomic::Configurator.app_id, SpreeConomic::Configurator.app_token
        @economic
      end
    end

    # Creates or updates a debtor in e-conomic
    #
    # @param user [Spree::User]
    # @return [Economic::Debtor]
    def upsert_debtor(user)
      debtor_number = SpreeConomic::Configurator.debtor_number.call(user)
      debtor = economic.debtors.find_by_number(debtor_number) || economic.debtors.build
      debtor.number = debtor_number
      debtor.debtor_group_handle = { number: Configurator.debtor_group_handle.call(user) }
      debtor.name = debtor_name(user.bill_address)
      debtor.address = user.bill_address.address1
      debtor.postal_code = user.bill_address.zipcode
      debtor.city = user.bill_address.city
      debtor.country = user.bill_address.country.iso_name
      debtor.telephone_and_fax_number = user.bill_address.phone
      debtor.email = user.email
      debtor.vat_zone = 'HomeCountry' # HomeCountry, EU, Abroad
      debtor.currency_handle = { code: 'DKK' }
      debtor.is_accessible = true
      debtor.ci_number = Configurator.vat_number.call(user)
      debtor.term_of_payment_handle = { id: Configurator.term_of_payment_handle.call(user) }
      debtor.layout_handle = { id: Configurator.layout_handle.call(user) }
      puts debtor.inspect
      debtor.save
      debtor
    end

    def upsert_product(spree_variant)
      product = economic.products.find_by_number(spree_variant.sku) || economic.products.build(number:spree_variant.sku)

      product.number = spree_variant.sku
      product.product_group_handle = { number: Configurator.product_group_handle.call(spree_variant) }
      product.name = spree_variant.name
      product.sales_price = spree_variant.price
      product.cost_price = spree_variant.cost_price
      product.recommended_price = spree_variant.price
      product.volume = 1
      product.is_accessible = true
      product.save
    end

    def create_invoice(order, debtor)
      c = economic.current_invoices.build(debtor: debtor)
      c.date = Time.now
      c.due_date = Time.now
      c.delivery_date = Time.now

      c.is_vat_included = true
      c.exchange_rate = 100
      c.currency_handle = debtor.currency_handle
      c.term_of_payment_handle = debtor.term_of_payment_handle

      c.debtor_name = debtor.name
      c.debtor_address = debtor.address
      c.debtor_postal_code = debtor.postal_code
      c.debtor_city = debtor.city
      c.debtor_country = debtor.country

      # create invoice lines and adjustments for products
      order.line_items.each do |line_item|
        # product line
        c.lines << create_invoice_line_from_item(line_item)
        # product discounts
        line_item.adjustments.promotion.eligible.group_by(&:label).each do |label, adjustments|
          c.lines << create_invoice_line(
            sku: line_item.product.sku,
            qty: 1,
            description: label.to_s,
            price: adjustments.sum(&:amount).to_f
          )
        end
      end
      # create invoice lines for order discounts
      order.adjustments.promotion.eligible.group_by(&:label).each do |label, adjustments|
        c.lines << create_invoice_line(
        sku: Configurator.discount_product_number.call(label),
        qty: 1,
        description: label.to_s,
        price: adjustments.sum(&:amount).to_f
        )
      end
      # create invoice lines for shipping
      if order.shipment_total > 0.0
        c.lines << create_invoice_line(
          sku: Configurator.shipping_product_number.call(order.shipments.first.shipping_method),
          qty: 1,
          description: order.shipments.first.shipping_method.name,
          price: order.shipment_total.to_f
        )
      end
      c.save
      c
    end

    def create_invoice_line_from_item(line_item)
      create_invoice_line(
        sku: line_item.product.sku,
        qty: line_item.quantity,
        description: line_item.product.name,
        price: line_item.price
      )
    end

    def create_invoice_line(sku:, qty:, description:, price:)
      l = Economic::CurrentInvoiceLine.new
      l.product_handle = economic.products.find(sku).handle
      l.quantity = qty
      l.description = description
      l.unit_net_price = price
      l
    end

    def debtor_name(bill_address)
      bill_address.company || bill_address.full_name
    end
  end
end
