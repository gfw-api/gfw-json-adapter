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

class Dataset < ApplicationRecord
  FORMAT  = %w(JSON).freeze
  STATUS  = %w(pending active disabled).freeze
  HORIZON = %w(infinitely).freeze

  after_create :update_data_columns, if: 'data[0].present? && data_columns == data.first'
  before_save  :set_data_count,      if: 'data[0].present? && data_changed?'

  before_update :assign_slug

  before_validation(on: [:create, :update]) do
    check_slug
  end

  validates :name, presence: true
  validates :slug, presence: true, format: { with: /\A[^\s!#$%^&*()（）=+;:'"\[\]\{\}|\\\/<>?,]+\z/,
                                             allow_blank: true,
                                             message: 'invalid. Slug must contain at least one letter and no special character'
                                           }
  validates_uniqueness_of :name, :slug

  scope :recent,           -> { order('updated_at DESC') }
  scope :filter_pending,   -> { where(status: 0)         }
  scope :filter_actives,   -> { where(status: 1)         }
  scope :filter_inactives, -> { where(status: 2)         }

  def format_txt
    FORMAT[format - 0]
  end

  def status_txt
    STATUS[status - 0]
  end

  def horizon_txt
    HORIZON[data_horizon - 0]
  end

  class << self
    def execute_data_query(sql_to_run)
      sql = sanitize_sql(sql_to_run)
      connection.select_all(sql)
    end

    def notifier(object_id, status=nil)
      DatasetServiceJob.perform_later(object_id, status)
    end

    def find_by_id_or_slug(param)
      dataset_id = where(slug: param).or(where(id: param)).pluck(:id).min
      find(dataset_id) rescue nil
    end

    def fetch_all(options)
      status = options['status'] if options['status'].present?

      case status
      when 'pending'  then filter_pending.recent
      when 'active'   then filter_actives.recent
      when 'disabled' then filter_inactives.recent
      when 'all'      then recent
      else
        filter_actives.recent
      end
    end
  end

  private

    def check_slug
      self.slug = self.name.downcase.parameterize if self.name.present? && self.slug.blank?
    end

    def assign_slug
      self.slug = self.slug.downcase.parameterize
    end

    def update_data_columns
      update_attributes(data_columns: ActiveRecord::Base.connection.execute(update_meta_data).map { |v| { v['key'] => { type: v['type'] } } })
    end

    def set_data_count
      self.row_count = self.data.length
    end

    def update_meta_data
      dataset_id = ActiveRecord::Base.send(:sanitize_sql_array, ['id = :dataset_id', dataset_id: self.id])
      <<-SQL
        with types AS (
          SELECT
              json_data.key AS key,
              CASE WHEN left(json_data.value::text,1) = '"'  THEN 'string'
                   WHEN json_data.value::text ~ '^-?\d' THEN
                      CASE WHEN json_data.value::text ~ '\.' THEN 'number'
                           ELSE 'integer'
                      END
                   WHEN left(json_data.value::text,1) = '['  THEN 'array'
                   WHEN left(json_data.value::text,1) = '{'  THEN 'object'
                   WHEN json_data.value::text in ('true', 'false')  THEN 'boolean'
                   WHEN json_data.value::text = 'null'  THEN 'null'
                   ELSE 'integer'
              END AS type
          FROM datasets, jsonb_each(datasets.data_columns) AS json_data WHERE #{dataset_id}
        )
        SELECT * from types;
      SQL
    end
end
