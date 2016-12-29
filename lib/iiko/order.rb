require 'securerandom'

module Iiko
  class Order
    attr_accessor :raw_order

    def initialize(args={})
      @raw_order = { id: SecureRandom.uuid, date: Time.now.utc.strftime('%Y-%m-%d %H:%M:%S'), full_sum: 0 }
      @raw_order.merge!(args)
    end

    def add_item(item)
      items = raw_order[:items] || []
      items << item
      raw_order[:full_sum] = raw_order[:full_sum] + item[:price]
      raw_order[:items] = items
    end

    # format: {city: 'City', street: 'Street', home: 'x', apartment: 'y'}
    def add_address(address={})
      raw_order[:address] = address
    end

    def make_request_order(client, customer)
      raw_order[:phone] = customer[:phone]
      { organization: client.current_organization[:id], customer: customer, order: raw_order }
    end
  end
end