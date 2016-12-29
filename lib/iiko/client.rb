require 'httparty'

module Iiko
  class ClientAPI

    class << self
      attr_accessor :display_name
      attr_accessor :base_url
    end

    self.display_name             = 'Iiko'
    self.base_url                 = 'https://iiko.biz:9900/api/0'

    attr_reader :userid, :usersecret, :current_organization

    def initialize(userid, usersecret, args = {})
      # required args
      @userid = userid
      @usersecret = usersecret
      # optional args
      @debug_mode = args[:debug_mode]
      @current_organization = args[:current_organization] || self.get_organization_list.first
    end

    def get_token
      # TODO кэш не работает
      Rails.cache.fetch("iiko/auth_token/#{userid}", expires_in: 14.minute) do
        url = "#{self.class.base_url}/auth/access_token"
        do_request('get', url, query: { user_id: self.userid, user_secret: self.usersecret })
      end
    end

    # return array [{:name=>"Org Name", :id=>"fsjvfhrt-ffgd-dgddfgd-dfgdfg-fglfkldfkg"}]
    def get_organization_list
      url = "#{self.class.base_url}/organization/list"
      org_list = []

      result = do_request('get', url, query: { access_token: self.get_token })

      result.each do |org|
        org_item = {}
        org_item.merge!(name: org['name'], id: org['id'])
        org_list << org_item
      end
      org_list
    end

    def get_nomenclature
      url = "#{self.class.base_url}/nomenclature/#{self.current_organization[:id]}"

      do_request('get', url, query: { access_token: self.get_token })
    end

    def get_payment_types
      url = "#{self.class.base_url}/rmsSettings/getPaymentTypes"

      do_request('get', url, query: { access_token: self.get_token, organization: self.current_organization[:id] })
    end

    # example optional args:
    #   isSelfService: true - self-pickup delivery parameter
    def create_order(args={})
      Order.new(args)
    end

    def add_order(order)
      url = "#{self.class.base_url}/orders/add"

      do_request('post', url, query: { access_token: self.get_token}, :body => order.to_json)
    end

    private

    def do_request(method, url, query = {})
      query.merge!(debug_output: $stdout) if @debug_mode
      if !query.empty? && method == 'post'
        query[:headers] = { 'Content-Type' => 'application/json; charset=utf-8' }
      end

      response = HTTParty.send(method, url, query)

      if response.success?
        response.parsed_response
      else
        raise StandardError, response.message
      end
    end
  end
end
