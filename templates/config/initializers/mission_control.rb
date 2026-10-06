# frozen_string_literal: true

# HTTP basic for /jobs. ENV (`.env` locally) overrides credentials so a
# machine can use a different password without editing the shared file.
# Do not call AppConfig here: initializers run before app/ autoload.
Rails.application.configure do
  creds = Rails.application.credentials
  config.mission_control.jobs.http_basic_auth_user =
    ENV["MISSION_CONTROL_USER"].presence ||
    creds.dig(:mission_control, :http_basic_auth_user) ||
    "admin"
  config.mission_control.jobs.http_basic_auth_password =
    ENV["MISSION_CONTROL_PASSWORD"].presence ||
    creds.dig(:mission_control, :http_basic_auth_password) ||
    "admin"
end
