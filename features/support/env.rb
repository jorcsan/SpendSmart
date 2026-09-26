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