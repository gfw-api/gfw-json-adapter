Rails.application.routes.draw do
  scope module: :v1, constraints: APIVersion.new(version: 1, current: true) do
    get    'summary',           to: 'connectors#index'
    get    'summary/:id',       to: 'connectors#details'
    post   'summary/:id/query', to: 'connectors#show'
    post   'summary/new',       to: 'connectors#create'
    delete 'summary/:id',       to: 'connectors#destroy'
  end
end
