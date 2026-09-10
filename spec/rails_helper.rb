# This file is loaded by specs that need the full Rails environment.
# Pure unit specs can require only spec_helper and stay fast.
require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

# Prevent a production database from ever being wiped by the suite.
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

# Load any shared examples, helpers, and matchers in spec/support.
Rails.root.glob("spec/support/**/*.rb").sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [ Rails.root.join("spec/fixtures") ]

  # Each example runs inside a transaction that is rolled back afterwards, so
  # examples stay independent and repeatable.
  config.use_transactional_fixtures = true

  # Derive the spec type (:model, :request, :system) from the file location.
  config.infer_spec_type_from_file_location!

  # Trim Rails' own frames out of backtraces.
  config.filter_rails_from_backtrace!
end
