require 'json'

module ErrataClient
  class Advisory < Base
    CONFIG = {
      :suffix => "advisory"
    }

    def initialize(params = {})
      self.class.config(params[:url])
      params.delete(:url)
      define_instance(params)
      self
    end

    def self.config(url)
      super(url)
    end

    def self.find(params = {})
      raise "Must specify an advisory Id to find" unless params.include?(:id)
      config(params[:url])
      Array(params[:id]).collect do |id|
        raw_data = execute(:get, "#{CONFIG[:suffix]}/#{id}")
        raw_data.nil? ? {} : Advisory.new(JSON.parse(raw_data))
      end
    end

    def self.all(params = {})
      config(params[:url])
      raw_data = execute(:get, "errata")
      raw_data.nil? ? [] : JSON.parse(raw_data).collect { |advisory| Advisory.new(advisory) }
    end

    def self.advisories(params = {})
      raise "Must specify a Bug Id to find advisories it belongs to" unless params.include?(:id)
      config(params[:url])
      raw_data = execute(:get, "#{Bug::CONFIG[:suffix]}/#{params[:id]}/advisories")
      raw_data.nil? ? [] : JSON.parse(raw_data).collect { |advisory| Advisory.new(advisory) }
    end

    def bugs
      suffix = "#{CONFIG[:suffix]}/#{id}/#{Bug::CONFIG[:suffix]}"
      Bug.parse_raw_data(self.class.execute(:get, suffix))
    end

    def builds
      suffix = "#{CONFIG[:suffix]}/#{id}/#{Build::CONFIG[:suffix]}"
      Build.parse_raw_data(self.class.execute(:get, suffix))
    end

    def rpmdiff_runs
      suffix = "#{CONFIG[:suffix]}/#{id}/#{RpmdiffRun::CONFIG[:suffix]}"
      RpmdiffRun.parse_raw_data(self.class.execute(:get, suffix))
    end

    def tps_jobs
      suffix = "#{CONFIG[:suffix]}/#{id}/#{TpsJob::CONFIG[:suffix]}"
      TpsJob.parse_raw_data(self.class.execute(:get, suffix))
    end
  end
end
