require 'spec_helper'

describe "Configurator" do
  describe ".config" do
    it "stores configuration data" do
      configure_spreeconomic

      assert_equal 1, SpreeConomic::Configurator.layout_handle.call(nil)
    end
  end
end
