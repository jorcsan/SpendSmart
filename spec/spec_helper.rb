# Coverage must be started before any application code is loaded, otherwise
# lines executed during boot are reported as uncovered.
require "simplecov"

SimpleCov.start "rails" do
  # Generated scaffolding and framework glue are not our logic to test.
  skip "app/jobs/application_job.rb"
  skip "app/mailers/application_mailer.rb"
  skip "app/models/application_record.rb"
  skip "app/channels"

  group "Models", "app/models"
  group "Controllers", "app/controllers"
  group "Helpers", "app/helpers"

  # The course rubric asks for at least 80% statement coverage. Failing the
  # suite here keeps the number from silently drifting downwards. Override it
  # (MINIMUM_COVERAGE=0 bin/rspec) while working on a feature whose specs are
  # not written yet; CI always runs with the default.
  minimum_coverage Integer(ENV.fetch("MINIMUM_COVERAGE", 80))
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Surface the slowest examples so the suite stays fast enough to run often.
  config.profile_examples = 5

  # Randomised order proves the specs do not depend on each other, which the
  # rubric calls out explicitly.
  config.order = :random
  Kernel.srand config.seed
end
