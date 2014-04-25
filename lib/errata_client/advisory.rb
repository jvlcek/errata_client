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

    def query_related_objects(klass)
      klass.parse_raw_data(self.class.execute(:get, "#{CONFIG[:suffix]}/#{id}/#{klass::CONFIG[:suffix]}"))
    end

    def bugs
      query_related_objects(Bug)
    end

    def builds
      query_related_objects(Build)
    end

    def rpmdiff_runs
      query_related_objects(RpmdiffRun)
    end

    def tps_jobs
      query_related_objects(TpsJob)
    end
  end
end
