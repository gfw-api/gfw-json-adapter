module V1
  class ConnectorsController < ApplicationController
    before_action :basic_auth,       only: [:update, :create, :destroy]
    before_action :set_dataset,      only: [:show, :update, :destroy]
    before_action :set_connector,    only: :data
    before_action :set_query_filter, only: :data
    before_action :set_uri,          only: :data

    def index
      @connectors = Dataset.fetch_all(dataset_type_filter)
      render json: @connectors, each_serializer: DatasetArraySerializer, root: false
    end

    def show
      render json: @dataset, serializer: DatasetSerializer, root: false
    end

    def data
      render json: @connector, serializer: ConnectorSerializer, query_filter: @query_filter, root: false
    end

    def update
      if @dataset.update(connector_params)
        render json: @dataset, status: 201, serializer: DatasetSerializer, root: false
      else
        render json: { success: false, message: 'Error updateding dataset' }, status: 422
      end
    end

    def create
      begin
        @dataset = JsonConnector.build_dataset(connector_params)
        if @dataset.save
          render json: @dataset, status: 201, serializer: DatasetSerializer, root: false
        else
          render json: { success: false, message: 'Error creating dataset' }, status: 422
        end
      rescue
        render json: { success: false, message: 'Error creating dataset' }, status: 422
      end
    end

    def destroy
      @dataset.destroy
      begin
        render json: { message: 'Dataset deleted' }, status: 200
      rescue ActiveRecord::RecordNotDestroyed
        return render json: @dataset.erors, message: 'Dataset could not be deleted', status: 422
      end
    end

    private

      def set_connector
        @connector = JsonConnector.new(params)
      end

      def set_dataset
        @dataset = Dataset.find_by_id_or_slug(params[:id])
      end

      def set_query_filter
        @query_filter = {}
        @query_filter['select']     = params[:select]     if params[:select].present?
        @query_filter['order']      = params[:order]      if params[:order].present?
        @query_filter['filter']     = params[:filter]     if params[:filter].present?
        @query_filter['filter_not'] = params[:filter_not] if params[:filter_not].present?
        @query_filter['aggr_by']    = params[:aggr_by]    if params[:aggr_by].present?
        @query_filter['aggr_func']  = params[:aggr_func]  if params[:aggr_func].present?
      end

      def set_uri
        @uri = {}
        @uri['api_gateway_url'] = ENV['API_GATEWAY_URL'] if ENV['API_GATEWAY_URL'].present?
        @uri['full_path']       = request.fullpath
      end

      def dataset_type_filter
        params.permit(:status)
      end

      def notify(status=nil)
        Dataset.notifier(connector_params[:id], status) if ENV['API_DATASET_META_URL'].present?
      end

      def meta_data_params
        @connector.recive_dataset_meta[:dataset]
      end

      def connector_params
        params.require(:connector).permit!
      end
  end
end
