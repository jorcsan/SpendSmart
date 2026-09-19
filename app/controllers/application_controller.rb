class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token, if: -> {
    request.headers["Accept"].to_s.include?("application/json")
  }

  before_action :authenticate_cli, if: -> {
    request.headers["Accept"].to_s.include?("application/json")
  }

  private

  def authenticate_cli
    authorization = request.headers["Authorization"]
    expected_token = ENV["SPENDSMART_API_TOKEN"]

    unless authorization == "Bearer #{expected_token}"
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
