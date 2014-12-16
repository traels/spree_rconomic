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
  # these will be called with a order if configured with a proc
  c.layout_handle = 16
  c.term_of_payment_handle = 2
  c.debtor_group_handle = 1
  # proc will be called with a user
  c.debtor_number = ->(user) { 10_000 + user.id }
  c.vat_number = ->(user) { 12_300_000 + user.id }
  # proc will be called with a variant
  c.product_group_handle = 1
  # proc will be called with first shipping method from order
  c.shipping_product_number = 'SKU-1'
  # proc will be called with label from adjustments
  c.discount_product_number = 'SKU-2'
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
