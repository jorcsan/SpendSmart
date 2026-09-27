require "simplecov"

SimpleCov.start do
  root Dir.pwd

  merge_timeout 3600

  skip "config/"
  skip "db/"
  skip "lib/"
  skip "test/"
  skip "spec/"
  skip "features/"

  group "Models", "app/models"
  group "Controllers", "app/controllers"
  group "CLI", "bin/cli_package"

  minimum_coverage 80
end

require_relative "../../config/environment"
require "rspec/expectations"
require "stringio"

def capture_stdout
  original_stdout = $stdout
  $stdout = StringIO.new

  yield

  $stdout.string
ensure
  $stdout = original_stdout
end