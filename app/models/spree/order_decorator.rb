Spree::Order.class_eval do
  register_update_hook :my_update_hook

  def my_update_hook
    warn reload.shipment_state
    SpreeConomic::OrderInvoicer.new.transfer(self) if reload.shipment_state == "shipped"
  end
end
