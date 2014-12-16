require 'spec_helper'

describe "Order", :type => :feature do
  stub_authorization!

  let!(:order) { create(:order_ready_to_ship, :number => "R100", :state => "complete", :line_items_count => 5) }

  context "shipping an order", js: true do
    before(:each) do
      configure_spreeconomic
      visit spree.admin_path
      click_link "Orders"
      within_row(1) do
        click_link "R100"
      end
    end

    it "can ship a completed order" do
      click_link "ship"
      wait_for_ajax

      expect(page).to have_content("SHIPPED PACKAGE")
      expect(order.reload.shipment_state).to eq("shipped")
    end

    it "creates an invoice in e-conomic" do
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

      click_link "ship"
      wait_for_ajax
    end
  end

end
