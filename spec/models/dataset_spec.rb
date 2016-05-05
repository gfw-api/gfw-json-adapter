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

require 'rails_helper'

RSpec.describe Dataset, type: :model do
  let!(:data_columns) {Oj.dump({
                                "pcpuid": {
                                  "type": "string"
                                },
                                "the_geom": {
                                  "type": "geometry"
                                },
                                "cartodb_id": {
                                  "type": "number"
                                },
                                "the_geom_webmercator": {
                                  "type": "geometry"
                                }
                              })}

  let!(:data) {Oj.dump([{
                          "pcpuid": "350558",
                          "the_geom": "0101000020E610000000000000786515410000000078651541",
                          "cartodb_id": 2
                        },
                        {
                          "pcpuid": "350659",
                          "the_geom": "0101000020E6100000000000000C671541000000000C671541",
                          "cartodb_id": 3
                        },
                        {
                          "pcpuid": "481347",
                          "the_geom": "0101000020E6100000000000000C611D41000000000C611D41",
                          "cartodb_id": 4
                        },
                        {
                          "pcpuid": "120171",
                          "the_geom": "0101000020E610000000000000B056FD4000000000B056FD40",
                          "cartodb_id": 5
                        },
                        {
                          "pcpuid": "500001",
                          "the_geom": "0101000020E610000000000000806EF84000000000806EF840",
                          "cartodb_id": 1
                      }])}

  let!(:data_copy) {Oj.dump({
                             "pcpuid": "350558",
                             "the_geom": "0101000020E610000000000000786515410000000078651541",
                             "cartodb_id": 2
                           })}

  let!(:generated_data_columns) {Oj.dump([{"pcpuid": {"type": "string"}},
                                          {"the_geom": {"type": "string"}},
                                          {"cartodb_id": {"type": "integer"}}
                                        ])}

  let!(:datasets) {
    datasets = []
    datasets << Dataset.create!(data: Oj.load(data), data_columns: Oj.load(data_columns), name: 'First test dataset',  slug: 'first-test-dataset')
    datasets << Dataset.create!(data: Oj.load(data), data_columns: Oj.load(data_copy),    name: 'Second test dataset', slug: 'second-test-dataset')
    datasets << Dataset.create!(data: Oj.load(data), data_columns: Oj.load(data_columns), name: 'Third test dataset')
    datasets.each(&:reload)
  }

  let!(:dataset_first)  { datasets[0]}
  let!(:dataset_second) { datasets[1] }
  let!(:dataset_third)  { datasets[2] }

  it 'Is valid' do
    expect(dataset_first).to              be_valid
    expect(dataset_first.data_columns).to eq(Oj.load(data_columns))
    expect(dataset_first.slug).to         eq('first-test-dataset')
  end

  it 'Update data columns after create' do
    expect(dataset_second.data_columns).to eq(Oj.load(generated_data_columns))
  end

  it 'Update row count after create' do
    expect(dataset_third.row_count).to eq(5)
  end

  it 'Generate slug after create' do
    expect(dataset_third.slug).to eq('third-test-dataset')
  end

  it 'Do not allow to create dataset without name' do
    dataset_reject = Dataset.new(name: '', slug: 'test')

    dataset_reject.valid?
    expect {dataset_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'Do not allow to create dataset with wrong slug' do
    dataset_reject = Dataset.new(name: 'test', slug: 'test&')

    dataset_reject.valid?
    expect {dataset_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Slug invalid. Slug must contain at least one letter and no special character")
  end

  it 'Do not allow to create dataset with name douplications' do
    expect(dataset_first).to be_valid
    dataset_reject = Dataset.new(name: 'First test dataset', slug: 'test')

    dataset_reject.valid?
    expect {dataset_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
  end
end
