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
      parse_typed_raw_data(raw_data, Bug)
    end
  end
end
