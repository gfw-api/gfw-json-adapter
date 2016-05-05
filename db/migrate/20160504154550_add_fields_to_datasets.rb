class AddFieldsToDatasets < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :name,        :string, null: false
    add_column :datasets, :slug,        :string
    add_column :datasets, :units,       :string
    add_column :datasets, :description, :text
    add_column :datasets, :format,      :integer, default: 0
    add_column :datasets, :row_count,   :integer, default: 0
    add_column :datasets, :status,      :integer, default: 0

    add_index :datasets, ['slug'], name: 'index_datasets_on_slug', unique: true
  end
end
