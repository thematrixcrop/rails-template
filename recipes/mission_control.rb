# frozen_string_literal: true

add_gem "mission_control-jobs"
copy_forced "config/initializers/mission_control.rb"

unless file_contains?("config/routes.rb", "MissionControl::Jobs::Engine")
  insert_into_file "config/routes.rb", after: "Rails.application.routes.draw do\n" do
    %(  mount MissionControl::Jobs::Engine, at: "/jobs"\n\n)
  end
end
