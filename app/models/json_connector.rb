require 'oj'

class JsonConnector
  include ActiveModel::Serialization
  attr_reader :id

  def initialize(params)
    @dataset_params = params
    initialize_options
  end

  def data(options = {})
    get_data = JsonService.new(@id, options)
    get_data.connect_data
  end

  def data_columns
    Dataset.find_by_id_or_slug(@id).try(:data_columns)
  end

  def self.build_dataset(options)
    dataset_url = options['connector_url'] if options['connector_url'].present?
    data_path   = options['data_path']     if options['data_path'].present?
    params = {}
    params['data'] = if options['connector_url'].present? && options['data'].blank?
                       ConnectorService.connect_to_provider(dataset_url, data_path)
                     else
                       data = Oj.dump(options['data'])
                       Oj.load(data)
                     end

    params['id']           = options['id']
    params['name']         = options['name']
    params['slug']         = options['slug']
    params['status']       = options['status'].present? ? options['status'] : 0
    params['format']       = options['format'].present? ? options['format'] : 0
    params['units']        = options['units']
    params['description']  = options['description']
    params['data_horizon'] = options['data_horizon'].present? ? options['data_horizon'] : 0

    params['data_columns'] = if options['connector_url'].present? && options['data_columns'].blank?
                               params['data'].first
                             else
                               data_columns = Oj.dump(options['data_columns'])
                               Oj.load(data_columns)
                             end
    Dataset.new(params)
  end

  private

    def initialize_options
      @options = DatasetParams.sanitize(@dataset_params)
      @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    end
end
