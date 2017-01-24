module Iiko
  class Address

    # list regions for organization
    def get_regions(client)
      url = "#{Iiko::ClientAPI.base_url}/regions/regions"

      client.do_request('get', url, query: { access_token: client.get_token, organization: client.current_organization[:id] })
    end

    # list cities for organization
    def get_list_cities(client)
      url = "#{Iiko::ClientAPI.base_url}/cities/citiesList"

      client.do_request('get', url, query: { access_token: client.get_token, organization: client.current_organization[:id] })
    end

    # list streets for city
    def get_streets(client, city_id)
      url = "#{Iiko::ClientAPI.base_url}/streets/streets"

      client.do_request('get', url, query: { access_token: client.get_token, organization: client.current_organization[:id], city: city_id })
    end

    # list cities and streets
    def get_all_cities(client)
      url = "#{Iiko::ClientAPI.base_url}/cities/cities"

      client.do_request('get', url, query: { access_token: client.get_token, organization: client.current_organization[:id] })
    end

  end
end