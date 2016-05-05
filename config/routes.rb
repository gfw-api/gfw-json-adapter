Rails.application.routes.draw do
  scope module: :v1, constraints: APIVersion.new(version: 1, current: true) do
    get    'summary',           to: 'connectors#index'
    get    'summary/:id',       to: 'connectors#show'
    put    'summary/:id',       to: 'connectors#update'
    post   'summary/:id/query', to: 'connectors#data'
    post   'summary/new',       to: 'connectors#create'
    delete 'summary/:id',       to: 'connectors#destroy'
  end
end
