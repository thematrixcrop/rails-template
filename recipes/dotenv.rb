# frozen_string_literal: true

# Local development reads `.env` through the dotenv Railtie (development and
# test only). Production reads the process environment. Env-independent
# secrets and shared config live in Rails credentials.

add_gem "dotenv", group: %i[development test]

copy_forced ".env.example"
copy_forced "config/credentials.example.yml"

if File.exist?(".gitignore")
  if file_contains?(".gitignore", "/.env*")
    insert_unless_present ".gitignore", "!/.env.example\n", after: "/.env*\n"
  else
    insert_unless_present ".gitignore", "!/.env.example\n"
  end
end

if File.exist?(".env.example") && !File.exist?(".env")
  require "fileutils"
  FileUtils.cp ".env.example", ".env"
  say "Copied .env.example to .env", :green
end

if File.exist?("bin/setup") && !file_contains?("bin/setup", ".env.example")
  indented = <<~RUBY.gsub(/^/, "  ")
    puts "\\n== Copying .env.example to .env =="
    FileUtils.cp ".env.example", ".env" unless File.exist?(".env")

  RUBY

  if File.read("bin/setup").match?(/# puts "\\n== Copying sample files =="/)
    gsub_file "bin/setup",
              /^  # puts "\\n== Copying sample files ==".*?^  # end\n/m,
              indented
  else
    insert_into_file "bin/setup", indented,
                     after: "system(\"bundle check\") || system!(\"bundle install\")\n"
  end
end
