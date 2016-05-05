# == Schema Information
#
# Table name: datasets
#
#  id           :uuid             not null, primary key
#  data_columns :jsonb
#  data         :jsonb
#  data_horizon :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  name         :string           not null
#  slug         :string
#  units        :string
#  description  :text
#  format       :integer          default(0)
#  row_count    :integer
#  status       :integer          default(0)
#

class DatasetSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :units, :description, :meta

  def meta
    data = {}
    data['format']          = object.try(:format_txt)
    data['status']          = object.try(:status_txt)
    data['horizon']         = object.try(:horizon_txt)
    data['updated_at']      = object.try(:updated_at)
    data['created_at']      = object.try(:created_at)
    data['data_attributes'] = data_attributes
    data['rows']            = object.try(:row_count)
    data
  end

  def data_attributes
    object.data_columns
  end
end
