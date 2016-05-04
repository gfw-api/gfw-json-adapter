class DatasetParams < Hash
  def initialize(params)
    sanitized_params = {
      id: params[:id] || nil,
      name: params[:name] || nil,
      provider: params[:provider] || nil,
      format: params[:format] || nil,
      data_path: params[:data_path] || nil,
      data_horizon: params[:data_horizon] || nil,
      attributes_path: params[:attributes_path] || nil,
      data_columns: params[:data_columns] || {},
      data: params[:data] || [],
      connector_url: params[:connector_url] || nil
    }

    super(sanitized_params)
    merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end
end
