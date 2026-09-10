# Acceptance specs default to the fast in-process rack_test driver. Tag an
# example with `js: true` when it needs a real browser (e.g. Turbo confirms).
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
  end
end
