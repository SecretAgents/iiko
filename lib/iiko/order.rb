module Iiko
  class Order
    attr_accessor :raw_order

    # example optional args:
    #   isSelfService: true - self-pickup delivery parameter
    def initialize(args={})
      @raw_order = { id: SecureRandom.uuid, date: Time.now.utc.strftime('%Y-%m-%d %H:%M:%S'), full_sum: 0 }
      @raw_order.merge!(args)
    end

    # Выбор продукта из меню организации
    # обязательные параметры: СlientAPI, индекс (номер по порядку) выбираемого пункта в меню, количество единиц.
    def select_item(client, count_index, amount)
      nomenclature = client.get_nomenclature

      { id: nomenclature['products'][count_index]['id'],
        name: nomenclature['products'][count_index]['name'],
        amount: amount,
        price: nomenclature['products'][count_index]['price'] }
    end

    # Добавление выбранного продукта к заказу
    def add_item(item)
      items = raw_order[:items] || []
      items << item
      raw_order[:full_sum] = raw_order[:full_sum] + item[:price]
      raw_order[:items] = items
    end

    # format: {city: 'City', street: 'Street', home: 'x', apartment: 'y'}
    # TODO добавление улицы через streetId
    def add_address(address={})
      raw_order[:address] = address
    end

    # required args:
    #   "isProcessedExternally" => boolean
    # optional args:
    #   "isPreliminary" => boolean
    #   "isExternal" => boolean
    #   "additionalData" => string
    def add_payment_type(client, count_index, args={})
      pt = client.get_payment_types

      payments = []
      options = { "paymentType" => pt["paymentTypes"][count_index], "sum" => raw_order[:full_sum] }
      options.merge!(args) if args
      payments << options
      raw_order[:paymentItems] = payments
    end

    def make_request_order(client, customer)
      raw_order[:phone] = customer.raw_customer[:phone]
      { organization: client.current_organization[:id], customer: customer.raw_customer, order: raw_order }
    end

    def add_order(client, order)
      url = "#{Iiko::ClientAPI.base_url}/orders/add"

      client.do_request('post', url, query: { access_token: client.get_token }, :body => order.to_json)
    end

  end
end