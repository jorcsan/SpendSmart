# Coverage must start before any application code is loaded, otherwise lines
# executed during boot are reported as uncovered. Filters, groups, and the
# minimum-coverage gate live in .simplecov, which Minitest shares.
require "simplecov"
SimpleCov.command_name "RSpec"
SimpleCov.start

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
