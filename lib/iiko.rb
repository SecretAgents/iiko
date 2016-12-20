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

    attr_reader :userid, :usersecret

    def initialize userid, usersecret
      # Required args
      @userid = userid
      @usersecret = usersecret
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
        org_list
      else
        raise response.response
      end
    end

    def get_nomenclature(org_id)
      url = "#{self.class.base_url}/nomenclature/#{org_id}"

      response = HTTParty.send('get', url, query: { access_token: self.get_token })

      if response.success?
        response.parsed_response
      else
        raise response.response
      end
    end

  end
end

# client = Iiko::ClientAPI.new('name', 'password')
# list = client.get_organization_list
# nomenclature = client.get_nomenclature(list[0][:id]) # меню для первой огранизации из списка
