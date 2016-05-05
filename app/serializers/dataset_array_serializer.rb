class DatasetArraySerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :status

  def status
    object.status_txt
  end
end
