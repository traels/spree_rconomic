Spree::Api::ShipmentsController.class_eval do
  after_action :transfer_order_to_economic, only: [:ship]

  private

  def transfer_order_to_economic
    SpreeConomic::OrderInvoicer.new.transfer(@shipment.order) if SpreeConomic::Configurator.transfer_on_ship
  end
end
