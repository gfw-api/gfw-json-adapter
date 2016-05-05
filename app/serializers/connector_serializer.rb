class ConnectorSerializer < ActiveModel::Serializer
  attributes :id, :data_attributes, :data

  def data
    object.data(@query_filter)
  end

  def data_attributes
    object.data_columns
  end

  def initialize(object, options)
    super
    @query_filter = options[:query_filter]
    @uri          = options[:uri]
  end
end
