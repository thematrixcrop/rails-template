# frozen_string_literal: true

# Base for Administrate dashboards at /admin.
# Generate a dashboard after the first model:
#   bin/rails generate administrate:dashboard Model
# Replace HTTP basic with a real staff check once User exists.
module Admin
  class ApplicationController < Administrate::ApplicationController
    http_basic_authenticate_with name: ENV.fetch("ADMIN_USER", "admin"),
                                 password: ENV.fetch("ADMIN_PASSWORD", "admin")

    around_action :use_english

    private

    def use_english(&)
      I18n.with_locale(:en, &)
    end
  end
end
