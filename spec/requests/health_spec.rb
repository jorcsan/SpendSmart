require "rails_helper"

# Smoke test: proves the Rails environment, database, and request specs are all
# wired up. Feature specs replace this as real endpoints land.
RSpec.describe "Health check", type: :request do
  it "reports that the application booted" do
    get rails_health_check_path

    expect(response).to have_http_status(:ok)
  end
end
