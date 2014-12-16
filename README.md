SpreeRconomic
=============

Automatically transfer a shipped order to e-conomic.

Installation
------------

Add spree_rconomic and rconomic to your Gemfile:

```ruby
gem 'spree_rconomic', github: 'traels/spree_rconomic'
gem 'rconomic', github: 'lokalebasen/rconomic'
```

Configuration
-------------

Create a initializer with configuration for how Spree is to transfer your order to a e-conomic invoice.

```ruby
SpreeConomic::Configurator.config do |c|
  c.app_id = '_ID_OF_ECONOMIC_APP_'
  c.app_token = '_TOKEN_FOR_USER_AUTHORIZING_THE_APP_'
  c.transfer_on_ship = true   # if false you must transfer manually
  c.layout_handle = ->(order) { 16 }
  c.term_of_payment_handle = ->(order) { 2 }
  c.debtor_group_handle = ->(user) { 1 }
  c.debtor_number = ->(user) { 10_000 + user.id }
  c.vat_number = ->(user) { 12_300_000 + user.id }
  c.product_group_handle = ->(variant) { 1 }
  c.shipping_product_number = ->(shipping_method) { 'SKU-1' }
  c.discount_product_number = ->(label) { 'SKU-2' }
end
```

Except for the 3 first configurations a configuration can either be a value or a proc that will be called when order is transfered.

Limitations
-----------
* VAT is added to everything
* All customers in e-conomic are created as HomeCountry
* Currency in e-conomic is DKK
* And probably other stuff that I forgot

Copyright (c) 2014 Træls, released under the New BSD License
