host = ENV.fetch('REDIS_HOST') { 'localhost' }
port = ENV.fetch('REDIS_PORT') { 6379 }

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{host}:#{port}/12", namespace: "GfwAdapterJsonJson_#{Rails.env}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{host}:#{port}/12", namespace: "GfwAdapterJsonJson_#{Rails.env}" }
end
