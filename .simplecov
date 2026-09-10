# Shared coverage configuration. SimpleCov loads this file automatically on
# `require "simplecov"`, so both spec/spec_helper.rb (RSpec) and
# test/test_helper.rb (Minitest) get the same filters and the same gate.
#
# Results from the two suites merge into one coverage/index.html as long as they
# run within SimpleCov's merge timeout, so the reported number covers both.
SimpleCov.configure do
  load_profile "rails"

  # Generated framework glue is not our logic to test.
  skip "app/jobs/application_job.rb"
  skip "app/mailers/application_mailer.rb"
  skip "app/models/application_record.rb"
  skip "app/channels"

  group "Models", "app/models"
  group "Controllers", "app/controllers"
  group "Helpers", "app/helpers"

  # The course rubric asks for at least 80% statement coverage. Override it
  # (MINIMUM_COVERAGE=0) while a feature's specs are still being written; CI
  # runs the Minitest pass unchecked and enforces the gate on the merged result.
  minimum_coverage Integer(ENV.fetch("MINIMUM_COVERAGE", 80))
end
