module ErrataClient
  class Base
    CONFIG = {
      :format => "json",
    }

    attr_reader :attribute_names

    def initialize(url)
      self.class.config(url)
    end

    def self.config(url = nil)
      @url = url || @url
    end

    def self.client
      @curl ||= begin
        curl = Curl::Easy.new
        curl.ssl_verify_peer = false
        curl.ssl_verify_host = false
        curl.http_auth_types = :negotiate
        curl.userpwd = ':'
        curl
      end
    end

    def self.json_parse(json_response, response = {})
      return response if json_response.blank?
      JSON.parse(json_response)
    rescue
      response
    end

    def self.fetch_error_message(json_response)
      response = json_parse(json_response)
      emsg = response["error"] || response["errors"] || ""
      emsg.kind_of?(Hash) ? emsg.values.flatten.join(", ") : emsg
    rescue
      ""
    end

    def self.execute(method, suffix = nil, params = nil)
      client_url(suffix)
      send("client_#{method}", params)
      return nil if client.response_code == 404
      if client.response_code >= 400
        etype = "#{client.response_code}: #{Rack::Utils::HTTP_STATUS_CODES[client.response_code]}:"
        raise "#{etype} #{fetch_error_message(client.body_str)}"
      end
      client.body_str
    end

    def self.client_url(suffix)
      use_url    = suffix.blank? ? @url.dup : "#{@url}/#{suffix}"
      client.url = "#{use_url}?format=#{CONFIG[:format]}"
    end

    def self.client_get(_params)
      client.perform
    end

    def self.client_post(params)
      raise "Must specify parameters for posts" if params.blank?
      client.http_post(client.url, params.to_query)
    end

    def define_instance(hash)
      @attribute_names = hash.keys
      hash.each do |k, v|
        instance_variable_set("@#{k}", v)
        self.class.class_eval { attr_reader k }
      end
    end

    def attributes
      @attribute_names.each_with_object({}) do |key, hash|
        hash[key] = instance_variable_get("@#{key}")
      end
    end

    def self.parse_typed_raw_data(raw_data, klass)
      json_parse(raw_data, []).collect { |item| klass.new(item) }
    end
  end
end
