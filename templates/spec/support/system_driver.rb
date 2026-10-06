# frozen_string_literal: true

# Browser specs (spec/system) cover Stimulus and Turbo behaviour.
#
# GitHub Ubuntu runners ship Chrome. A machine whose Chrome lives elsewhere:
#
#   CHROME_BIN=/path/to/chrome CHROMEDRIVER_PATH=/path/to/chromedriver bin/rspec spec/system
if ENV["CHROMEDRIVER_PATH"].present?
  Selenium::WebDriver::Chrome::Service.driver_path = ENV["CHROMEDRIVER_PATH"]
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1280, 900 ] do |options|
      options.binary = ENV["CHROME_BIN"] if ENV["CHROME_BIN"].present?
      options.add_argument("--no-sandbox")
      options.add_argument("--disable-dev-shm-usage")
    end
  end
end
