# frozen_string_literal: true

add_gem "rails-i18n"

copy_forced "app/lib/app_log.rb"
copy_forced "app/lib/app_config.rb"
template_forced "AGENTS.md.tt", "AGENTS.md"
template_forced "config/database.yml.tt", "config/database.yml"
copy_forced "config/cache.yml"
copy_forced "config/cable.yml"

if File.exist?(".gitignore")
  insert_unless_present ".gitignore", "/.gitlock\n"
  insert_unless_present ".gitignore", "/openspec/\n"
end

unless file_contains?("config/application.rb", "config.i18n.available_locales")
  environment <<~RUBY
    config.i18n.available_locales = [ :en, :"zh-CN" ]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [ :en ]
    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc

    config.generators do |g|
      g.test_framework :rspec, fixtures: true, view_specs: false, helper_specs: false, routing_specs: false
    end
  RUBY
end

gsub_file "config/environments/development.rb",
          /config\.cache_store = :memory_store/,
          "config.cache_store = :solid_cache_store"

unless file_contains?("config/environments/development.rb", "config.active_job.queue_adapter = :solid_queue")
  insert_into_file "config/environments/development.rb",
                   after: "config.cache_store = :solid_cache_store\n" do
    <<~RUBY

      config.active_job.queue_adapter = :solid_queue
      config.solid_queue.connects_to = { database: { writing: :queue } }
    RUBY
  end
end

unless file_contains?("config/environments/test.rb", "config.i18n.raise_on_missing_translations = true")
  gsub_file "config/environments/test.rb",
            /# config\.i18n\.raise_on_missing_translations = true/,
            "config.i18n.raise_on_missing_translations = true"
end

if File.exist?("config/ci.rb") && !file_contains?("config/ci.rb", 'bin/rspec')
  insert_into_file "config/ci.rb",
                   after: "step \"Security: Brakeman code analysis\", \"bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error\"\n" do
    <<~RUBY

      step "Tests: RSpec", "bin/rspec"
    RUBY
  end
end
