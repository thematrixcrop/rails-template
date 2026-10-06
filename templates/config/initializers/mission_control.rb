# frozen_string_literal: true

Rails.application.configure do
  config.mission_control.jobs.http_basic_auth_user =
    ENV.fetch("MISSION_CONTROL_USER", "admin")
  config.mission_control.jobs.http_basic_auth_password =
    ENV.fetch("MISSION_CONTROL_PASSWORD") do
      Rails.application.credentials.dig(:mission_control, :http_basic_auth_password) || "admin"
    end
end
