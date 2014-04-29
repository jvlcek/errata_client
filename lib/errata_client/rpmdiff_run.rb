module ErrataClient
  class RpmdiffRun < Advisory
    CONFIG = {
      :suffix => "rpmdiff_runs"
    }

    def initialize(params = {})
      define_instance(params)
      self
    end

    def self.parse_raw_data(raw_data)
      json_parse(raw_data, []).collect { |rpmdiff_run| RpmdiffRun.new(rpmdiff_run["rpmdiff_run"]) }
    end
  end
end
