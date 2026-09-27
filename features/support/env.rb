require_relative "../../config/environment"
require "rspec/expectations"
require "stringio"
require "simplecov"

SimpleCov.start do
  root Dir.pwd

  skip "app/"
  skip "config/"
  skip "db/"
  skip "lib/"
  skip "test/"
  skip "spec/"
  skip "features/"

  group "CLI", "bin/cli_package/definitions.rb"

  minimum_coverage 80
end

def capture_stdout
  original_stdout = $stdout
  $stdout = StringIO.new

  yield

  $stdout.string
ensure
  $stdout = original_stdout
end
