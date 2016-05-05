require 'acceptance_helper'

module V1
  describe 'Dataset', type: :request do
    context 'Create, update and delete datasets' do
      let!(:data_columns) {{
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
                          }}

      let!(:data) {[{
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
                  }]}

      let!(:params) {{"connector": {
                      "name": "First test dataset",
                      "data_columns": data_columns,
                      "data": data
                    }}}

      let!(:update_params) {{"connector": {
                             "name": "First test dataset update",
                             "slug": "updated-first-test-dataset"
                           }}}

      let!(:dataset) {
        Dataset.create!(data: data, data_columns: data_columns, name: 'Second test dataset', slug: 'second-test-dataset')
      }

      let!(:dataset_id)   { Dataset.first.id   }
      let!(:dataset_slug) { Dataset.first.slug }

      context 'List fliters' do
        let!(:disabled_dataset) {
          Dataset.create!(data: data, data_columns: data_columns, name: 'disabled dataset', slug: 'disabled-dataset', status: 2)
        }

        let!(:enabled_dataset) {
          Dataset.create!(data: data, data_columns: data_columns, name: 'enabled dataset', slug: 'enabled-dataset', status: 1)
        }

        it 'Show list of all datasets' do
          get '/summary?status=all'

          expect(status).to eq(200)
          expect(json.size).to eq(3)
        end

        it 'Show list of datasets with pending status' do
          get '/summary?status=pending'

          expect(status).to eq(200)
          expect(json.size).to eq(1)
        end

        it 'Show list of datasets with active status' do
          get '/summary?status=active'

          expect(status).to eq(200)
          expect(json.size).to eq(1)
        end

        it 'Show list of datasets with disabled status' do
          get '/summary?status=disabled'

          expect(status).to eq(200)
          expect(json.size).to eq(1)
        end

        it 'Show list of datasets' do
          get '/summary'

          expect(status).to eq(200)
          expect(json.size).to eq(1)
        end
      end

      it 'Show dataset by slug' do
        get "/summary/#{dataset_slug}"

        expect(status).to eq(200)
        expect(json['slug']).to    eq('second-test-dataset')
        expect(json['meta']['status']).to  eq('pending')
        expect(json['meta']['horizon']).to eq('infinitely')
        expect(json['meta']['format']).to  eq('JSON')
      end

      it 'Allows to create json dataset with data and data_attributes' do
        post '/summary/new', params: params

        expect(status).to eq(201)
        expect(json['id']).to   be_present
        expect(json['slug']).to eq('first-test-dataset')
      end

      it 'Allows to update dataset' do
        put "/summary/#{dataset_slug}", params: update_params

        expect(status).to eq(201)
        expect(json['id']).to   be_present
        expect(json['name']).to eq('First test dataset update')
        expect(json['slug']).to eq('updated-first-test-dataset')
      end

      it 'Allows to delete dataset' do
        delete "/summary/#{dataset_id}"

        expect(status).to eq(200)
        expect(json['message']).to eq('Dataset deleted')
        expect(Dataset.where(id: dataset_id)).to be_empty
      end

      it 'Allows to delete dataset by slug' do
        delete "/summary/#{dataset_slug}"

        expect(status).to eq(200)
        expect(json['message']).to eq('Dataset deleted')
        expect(Dataset.where(slug: dataset_slug)).to be_empty
      end
    end
  end
end
