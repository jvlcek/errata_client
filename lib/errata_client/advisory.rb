module ErrataClient
  class Advisory < Base
    CONFIG = {
      :suffix      => "advisory",
      :post_suffix => "api/v1/erratum"
    }

    def initialize(params = {})
      self.class.config(params[:url])
      params.delete(:url)
      define_instance(params)
      self
    end

    def self.fetch_advisory(id)
      json_parse(execute(:get, "#{CONFIG[:suffix]}/#{id}"))
    end

    def self.config(url = nil)
      super(url)
    end

    def self.find(params = {})
      raise "Must specify an advisory Id to find" unless params.include?(:id)
      config(params[:url])
      Array(params[:id]).collect do |id|
        advisory_hash = fetch_advisory(id)
        advisory_hash.empty? ? {} : Advisory.new(advisory_hash)
      end
    end

    def self.all(params = {})
      config(params[:url])
      raw_data = execute(:get, "errata")
      json_parse(raw_data, []).collect { |advisory| Advisory.new(advisory) }
    end

    def self.advisories(params = {})
      raise "Must specify a Bug Id to find advisories it belongs to" unless params.include?(:id)
      config(params[:url])
      raw_data = execute(:get, "#{Bug::CONFIG[:suffix]}/#{params[:id]}/advisories")
      json_parse(raw_data, []).collect { |advisory| Advisory.new(advisory) }
    end

    # Advisory Status Update Methods
    def post_suffix
      "#{CONFIG[:post_suffix]}/#{id}"
    end

    def status=(new_state)
      change_status(:new_state => new_state) unless @status == new_state
    end

    # change_status parameters:
    #   mandatory: :new_state
    #   optional:  :comment
    #
    def change_status(params)
      raise "Must specify a new_state parameter to update this advisory" if params[:new_state].blank?
      self.class.execute(:post, "#{post_suffix}/change_state", params)
      @status = params[:new_state]
    end

    # Advisory Bugzilla Issue Update Methods
    def manage_bug(suffix, bug_id)
      self.class.json_parse(self.class.execute(:post, suffix, :bug => bug_id))
    end

    def add_bug(bug_id)
      raise "Must specify a Bug Id to add to this advisory" if bug_id.blank?
      manage_bug("#{post_suffix}/add_bug", bug_id)
    end

    def remove_bug(bug_id)
      raise "Must specify a Bug Id to remove from this advisory" if bug_id.blank?
      manage_bug("#{post_suffix}/remove_bug", bug_id)
    end

    # Advisory Build Update Methods
    def manage_build(suffix, params)
      self.class.json_parse(self.class.execute(:post, suffix, params))
    end

    # add_build parameters:
    #   mandatory: :nvr, :product_version
    #
    def add_build(params)
      raise "Must specify a Build NVR to add to this advisory" if params[:nvr].blank?
      raise "Must specify a product_version for the NVR to add to this advisory" if params[:product_version].blank?
      manage_build("#{post_suffix}/add_build", params)
    end

    # remove_build parameters:
    #   mandatory: :nvr
    #
    def remove_build(params)
      raise "Must specify a Build NVR to remove from this advisory" if params[:nvr].blank?
      manage_build("#{post_suffix}/remove_build", params)
    end

    # Related Sub-Object Methods
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

    def reload
      define_instance(self.class.fetch_advisory(id))
      self
    end
  end
end
