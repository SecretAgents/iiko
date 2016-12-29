require 'securerandom'

module Iiko
  class Customer
    attr_reader :raw_customer

    def initialize(name, phone, args = {})
      # required args
      @raw_customer = { name: name, phone: phone }
      @raw_customer.merge!(args)
      # optional args
      @raw_customer[:id] ||= SecureRandom.uuid
    end
  end
end