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
      return [] if raw_data.nil?
      JSON.parse(raw_data).collect { |tps_job| TpsJob.new(tps_job) }
    end
  end
end
