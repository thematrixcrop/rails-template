# frozen_string_literal: true

# Two configuration stores:
#
# 1. ENV, plus `.env` / `.env.local` in development and test (dotenv).
#    Machine-specific and environment-specific values: database, APP_HOST,
#    log level. Production reads the process environment, not a file.
#
# 2. Rails credentials (`bin/rails credentials:edit`).
#    Shared across environments: OAuth client IDs, API tokens, third-party
#    secrets. One encrypted file. Production supplies RAILS_MASTER_KEY.
#    Layout: config/credentials.example.yml.
#
# Tests never read the real credentials file. Specs inject values with
# `AppConfig.with_overrides`. Add typed readers here as the app grows.
# A reader returns nil when its required values are missing, so callers
# can refuse a feature cleanly.
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

  # Env-independent value from credentials. `AppConfig.credential(:google, :client_id)`.
  def credential(*path)
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
