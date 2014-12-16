require 'spec_helper'

describe SpreeConomic::OrderInvoicer, :type => :model do
  let!(:order) { create(:order_ready_to_ship, :number => "R100", :state => "complete", :line_items_count => 5) }

  context 'invoicing an order' do
    before :each do
      configure_spreeconomic
      user = order.user
      user.bill_address = order.bill_address
      user.save
    end

    it 'creates a current invoice' do
      SpreeConomic::OrderInvoicer.new.transfer(order)
    end
  end
end
