class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  rescue_from Exception do |e|
    error(e)
  end

  def routing_error
    raise ActionController::RoutingError.new(params[:path])
  end

  protected

    def error(e)
      if request.env["ORIGINAL_FULLPATH"] =~ /^\//
        error_info = { error: "internal-server-error", exception: "#{e.class.name} : #{e.message}" }
        error_info[:trace] = e.backtrace[0,10] if Rails.env.development?
        render json: error_info.to_json, status: 500
      else
        raise e
      end
    end

    def basic_auth
      authenticate_or_request_with_http_basic("Administration") do |user, password|
        ENV["ACCESS_USER"] == user && ENV["ACCESS_PASSWORD"] == password
      end if ENV['ACCESS'].present? && ENV['ACCESS'].include?('private')
    end
end
