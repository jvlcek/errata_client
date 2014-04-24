require 'json'

module ErrataClient
  class Bug < Advisory
    CONFIG = {
      :suffix => "bugs"
    }

    def initialize(params = {})
      define_instance(params)
      self
    end

    def self.parse_raw_data(raw_data)
      return [] if raw_data.nil?
      JSON.parse(raw_data).collect { |bug| Bug.new(bug) }
    end
  end
end
