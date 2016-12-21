require "httparty"
require "iiko/version"

module Iiko
  class ClientAPI

    class << self
      attr_accessor :display_name
      attr_accessor :base_url
      attr_accessor :get_token_url
    end

    self.display_name             = 'Iiko'
    self.base_url                 = 'https://iiko.biz:9900/api/0'
    self.get_token_url            = '/auth/access_token'

    attr_reader :userid, :usersecret, :current_organization

    def initialize userid, usersecret
      # Required args
      @userid = userid
      @usersecret = usersecret
      list = self.get_organization_list
      @current_organization = list[0]
    end

    def get_token
      #url = "#{self.class.base_url}#{self.class.get_token_url}"
      #token = HTTParty.send('get', url, query: { user_id: self.userid, user_secret: self.usersecret })
      Rails.cache.fetch("iiko/auth_token/#{userid}", expires_in: 14.minute) do
        url = "#{self.class.base_url}#{self.class.get_token_url}"
        token = HTTParty.send('get', url, query: { user_id: self.userid, user_secret: self.usersecret }) #, :debug_output => $stdout)
        token.parsed_response
      end
    end

    # return org.list array [{:name=>"Org Name", :id=>"fsjvfhrt-ffgd-dgddfgd-dfgdfg-fglfkldfkg"}]
    def get_organization_list
      url = "#{self.class.base_url}/organization/list"
      org_list = []

      response = HTTParty.send('get', url, query: { access_token: self.get_token }) #, :debug_output => $stdout)

      if response.success?
        response.parsed_response.each do |org|
          org_item = {}
          org_item.merge!(name: org['name'], id: org['id'])
          org_list << org_item
        end
      else
        raise response.response
      end
    end

    def get_nomenclature
      org_id = @current_organization['id']
      url = "#{self.class.base_url}/nomenclature/#{org_id}"

      response = HTTParty.send('get', url, query: { access_token: self.get_token })

      if response.success?
        response.parsed_response
      else
        raise response.response
      end
    end

    def get_payment_types
      org_id = @current_organization['id']

      url = "#{self.class.base_url}/rmsSettings/getPaymentTypes"

      response = HTTParty.send('get', url, query: { access_token: self.get_token, organization: org_id })

      if response.success?
        response.parsed_response
      else
        raise response.response
      end
    end

    def new_order
      { date: Time.now.utc }
    end

    def add_item(order, item)
      items ||= []
      items << item
      order[:items] = items
    end


    def add_order(order_request)
      url = "#{self.class.base_url}/orders/add"

      response = HTTParty.send('post', url, query: { access_token: self.get_token, order_request: order_request }, :debug_output => $stdout)
    end

    private

    def do_request
      # HTTParty и обработка
    end

  end
end

# client = Iiko::ClientAPI.new('name', 'password')
# list = client.get_organization_list
# nomenclature = client.get_nomenclature(list[0][:id]) # меню для первой огранизации из списка
