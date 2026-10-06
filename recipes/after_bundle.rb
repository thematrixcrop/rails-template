# frozen_string_literal: true

generate "rspec:install" unless File.exist?("spec/rails_helper.rb")

if File.exist?("spec/rails_helper.rb") && !file_contains?("spec/rails_helper.rb", "webmock/rspec")
  helper = File.read("spec/rails_helper.rb")
  after_line = if helper.include?(%(require "rspec/rails"))
                 %(require "rspec/rails"\n)
  elsif helper.include?("require 'rspec/rails'")
                 "require 'rspec/rails'\n"
  end

  if after_line
    insert_into_file "spec/rails_helper.rb", after: after_line do
      <<~RUBY
        require "webmock/rspec"
        require "capybara/rspec"

        Rails.root.glob("spec/support/**/*.rb").sort_by(&:to_s).each { |file| require file }
      RUBY
    end
  else
    append_to_file "spec/rails_helper.rb", <<~RUBY

      require "webmock/rspec"
      require "capybara/rspec"
      Rails.root.glob("spec/support/**/*.rb").sort_by(&:to_s).each { |file| require file }
    RUBY
  end
end

run "bundle binstubs rspec-core" unless File.exist?("bin/rspec")
run "bundle exec lefthook install" if git_repo?
