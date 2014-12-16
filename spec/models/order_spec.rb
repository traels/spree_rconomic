require 'spec_helper'

describe Spree::Order, :type => :model do
  let!(:order) { create(:order_ready_to_ship, :number => "R100", :state => "complete", :line_items_count => 5) }

  context "ensure shipments will be updated" do
    context "except when order is completed, that's OrderInventory job" do
      it "doesn't touch anything" do
        mock_request(
        "CurrentInvoice_CreateFromData", {
          "data" => {
            "Id" => 512,
            "DebtorName" => nil,
            "AttentionHandle" => nil,
            "Date" => Time.now.iso8601,
            "TermOfPaymentHandle" => {"Id" => 37},
            "DueDate" => nil,
            "CurrencyHandle" => {"Code" => "BTC"},
            "ExchangeRate" => 100,
            "IsVatIncluded" => nil,
            "LayoutHandle" => {"Id" => 314},
            "DeliveryDate" => nil,
            "NetAmount" => 0,
            "VatAmount" => 0,
            "GrossAmount" => 0,
            "Margin" => 0,
            "MarginAsPercent" => 0
          }
        },
        :success
        )
        Spree::Shipment.create!(order: order)
        allow(order).to receive_messages completed?: true
        order.update_column(:shipment_total, 5)
        order.shipments.create!
        order.save

      end
    end
  end
end
