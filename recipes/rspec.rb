# frozen_string_literal: true

add_gem "rspec-rails", group: %i[development test]
add_gem "webmock", group: :test
add_gem "capybara", group: :test
add_gem "selenium-webdriver", group: :test

copy_forced "spec/support/webmock.rb"
copy_forced "spec/support/system_driver.rb"
copy_forced "spec/support/rails_config.rb"
copy_forced "spec/lib/app_log_spec.rb"
copy_forced "spec/lib/app_config_spec.rb"
