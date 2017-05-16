require 'httparty'

module Iiko
  class ClientAPI

    class << self
      attr_accessor :display_name
      attr_accessor :base_url
    end

    self.display_name             = 'Iiko'
    self.base_url                 = 'https://iiko.biz:9900/api/0'

    attr_reader :userid, :usersecret
    attr_accessor :current_organization

    def initialize(userid, usersecret, args = {})
      # required args
      @userid = userid
      @usersecret = usersecret
      # optional args
      @debug_mode = args[:debug_mode]
      @current_organization = args[:current_organization] || self.get_organization_list.first
    end

    # Получение токена для авторизации
    def get_token
      Rails.cache.fetch("iiko/auth_token/#{userid}", expires_in: 14.minutes) do
        url = "#{self.class.base_url}/auth/access_token"
        token = do_request('get', url, query: { user_id: self.userid, user_secret: self.usersecret })
        token
      end
    end

    # Список организаций
    # return Array [{:name=>"Org Name", :id=>"fsjvfhrt-ffgd-dgddfgd-dfgdfg-fglfkldfkg"}]
    def get_organization_list
      url = "#{self.class.base_url}/organization/list"
      org_list = []

      result = do_request('get', url, query: { access_token: self.get_token })

      result.each do |org|
        org_item = {}
        org_item.merge!(name: org['name'], id: org['id'], address: org['address'], address2: org['contact']['location'])
        org_list << org_item
      end
      org_list
    end

    # Получение номенклатуры (меню) организации
    def get_nomenclature
      url = "#{self.class.base_url}/nomenclature/#{self.current_organization[:id]}"

      do_request('get', url, query: { access_token: self.get_token })
    end

    # Получение стоп-листов по организации
    def get_stop_lists
      url = "#{self.class.base_url}/stopLists/getDeliveryStopList"

      do_request('get', url, query: { access_token: self.get_token, organization: self.current_organization[:id] })
    end

    # Получение списка терминалов доставки по организации
    def get_terminals
      url = "#{self.class.base_url}/deliverySettings/getDeliveryTerminals"

      do_request('get', url, query: { access_token: self.get_token, organization: self.current_organization[:id] })
    end

    # Получение типов оплат организации
    def get_payment_types
      url = "#{self.class.base_url}/rmsSettings/getPaymentTypes"

      do_request('get', url, query: { access_token: self.get_token, organization: self.current_organization[:id] })
    end

    # Получение списка доставочных ресторанов, подключённых к данному ресторану
    def get_delivery_terminals
      url = "#{self.class.base_url}/deliverySettings/getDeliveryTerminals"

      do_request('get', url, query: { access_token: self.get_token, organization: self.current_organization[:id] })
    end

    def do_request(method, url, query = {})
      query.merge!(debug_output: Rails.logger) if @debug_mode
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
