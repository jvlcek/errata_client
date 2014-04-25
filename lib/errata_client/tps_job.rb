require 'json'

module ErrataClient
  class TpsJob < Advisory
    CONFIG = {
      :suffix => "tps_jobs"
    }

    def initialize(params = {})
      define_instance(params)
      self
    end

    def self.parse_raw_data(raw_data)
      parse_typed_raw_data(raw_data, TpsJob)
    end
  end
end
