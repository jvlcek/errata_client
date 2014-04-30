module ErrataClient
  class Build < Advisory
    CONFIG = {
      :suffix => "builds"
    }

    def initialize(params = {})
      define_instance(params)
      self
    end

    def self.parse_raw_data(raw_data)
      result = []
      json_parse(raw_data, []).each do |product_version, builds|
        builds.each do |nvr_hashes|
          nvr_hashes.each do |nvr, nvr_hash|
            result << Build.new(
              "nvr"             => nvr,
              "product_version" => product_version,
              "nvr_data"        => nvr_hash
            )
          end
        end
      end
      result
    end

    def classifications
      @nvr_data.keys.sort.uniq
    end

    def architectures
      @nvr_data.collect { |_classification, data| data.keys }.flatten.sort.uniq
    end

    def rpms
      @nvr_data.collect { |_classification, data| data.values }.flatten.sort.uniq
    end
  end
end
