# Must come before config/environment so boot-time lines are counted. Shared
# configuration lives in .simplecov; results merge with the RSpec run.
require "simplecov"
# Set explicitly: SimpleCov's command guesser sees the RSpec constant (rspec-rails
# is loaded by Bundler.require in the test environment) and would label this run
# "RSpec" too, overwriting the other suite's result instead of merging with it.
SimpleCov.command_name "Minitest"
SimpleCov.start

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
