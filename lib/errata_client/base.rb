require 'json'
require 'curb'
require 'rack'

module ErrataClient
  class Base
    CONFIG = {
      :format => "json"
    }

    attr_reader :attribute_names

    def initialize(url)
      self.class.config(url)
    end

    def self.config(url)
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

    def self.execute(method, suffix = nil)
      use_url = suffix.nil? ? @url.dup : "#{@url}/#{suffix}"
      use_url = "#{use_url}?format=#{CONFIG[:format]}"
      client.url = use_url
      client.perform
      return nil if client.response_code == 404
      if client.response_code >= 400
        msg = Rack::Utils::HTTP_STATUS_CODES[client.response_code]
        raise "#{client.response_code} - #{msg}"
      end
      client.body_str
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
      return [] if raw_data.nil?
      JSON.parse(raw_data).collect { |item| klass.new(item) }
    end
  end
end
