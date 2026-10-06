# frozen_string_literal: true

# Typed access to configuration. Deployment settings (database, host) live in
# ENV. Secrets for third-party services live in Rails credentials
# (`bin/rails credentials:edit`). The test environment never reads the real
# credentials file; specs inject values with `AppConfig.with_overrides`.
#
# Add typed readers in this file as the app grows. A reader returns nil when
# its required values are missing, so callers can refuse a feature cleanly.
module AppConfig
  module_function

  def app_host
    ENV.fetch("APP_HOST", "localhost:3000")
  end

  def app_protocol
    ENV.fetch("APP_PROTOCOL", Rails.env.production? ? "https" : "http")
  end

  def app_url
    "#{app_protocol}://#{app_host}"
  end

  def value(*path)
    found = source.dig(*path)
    found.is_a?(String) ? found.strip.presence : found
  end

  def source
    @overrides || (Rails.env.test? ? {} : Rails.application.credentials.config)
  end

  def with_overrides(values)
    previous = @overrides
    @overrides = values.deep_symbolize_keys
    yield
  ensure
    @overrides = previous
  end
end
