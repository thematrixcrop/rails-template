# frozen_string_literal: true

# Rails application template. Loaded by `rails new -m` or bin/new.
# https://guides.rubyonrails.org/generators.html#application-templates

require "json"
require "net/http"
require "tmpdir"
require "fileutils"
require "yaml"

REPO_SLUG = "thematrixcrop/rails-template"
REPO_GIT = "https://github.com/#{REPO_SLUG}.git"

def add_template_repository_to_source_path
  dir = File.expand_path(File.dirname(__FILE__))
  local_recipes = File.join(dir, "recipes", "core.rb")

  if File.exist?(local_recipes)
    @template_root = dir
  else
    @template_root = Dir.mktmpdir("rails-template-")
    at_exit { FileUtils.remove_entry(@template_root) }
    say "Cloning #{REPO_GIT} into #{@template_root}", :green
    run "git clone --quiet --depth=1 #{REPO_GIT} #{@template_root}"
  end

  source_paths.unshift(File.join(@template_root, "templates"))
  source_paths.unshift(@template_root)
end

def template_config
  @template_config ||= YAML.safe_load_file(File.join(@template_root, "config.yml"))
end

def requested_modules
  from_env = ENV.fetch("RAILS_TEMPLATE_WITH", "").split(",").map(&:strip).reject(&:empty?)
  from_config = Array(template_config.dig("modules")).filter_map { |name, on| name if on }
  (from_env + from_config).uniq
end

def with?(name)
  requested_modules.include?(name.to_s)
end

def gem_declared?(name)
  File.read("Gemfile").match?(/^\s*gem\s+["']#{Regexp.escape(name)}["']/)
end

def add_gem(name, group: nil, **options)
  return if gem_declared?(name)

  kwargs = options.dup
  kwargs[:group] = group if group
  if group
    gem name, **kwargs
  else
    gem name, **kwargs
  end
end

def file_contains?(path, snippet)
  File.exist?(path) && File.read(path).include?(snippet)
end

def insert_unless_present(path, snippet = nil, **options, &block)
  return unless File.exist?(path)

  needle = snippet.presence || (block && block.call)
  return if file_contains?(path, needle.to_s.strip)

  content = block ? nil : snippet
  if options[:before] || options[:after]
    insert_into_file path, content, **options, &block
  else
    append_to_file path, content || block.call
  end
end

def copy_forced(source, dest = source)
  copy_file source, dest, force: true
end

def template_forced(source, dest = source.sub(/\.tt\z/, ""))
  template source, dest, force: true
end

def latest_gem_version(name)
  uri = URI("https://rubygems.org/api/v1/gems/#{name}.json")
  response = Net::HTTP.get_response(uri)
  return nil unless response.is_a?(Net::HTTPSuccess)

  JSON.parse(response.body)["version"]
rescue StandardError => error
  say "Unable to query Rubygems for #{name}: #{error.class}: #{error.message}", :yellow
  nil
end

def warn_if_rails_stale!
  latest = latest_gem_version("rails")
  return unless latest

  current = Rails::VERSION::STRING
  return if Gem::Version.new(current) >= Gem::Version.new(latest)

  say "Newer Rails #{latest} is on Rubygems (this run uses #{current}).", :yellow
  say "Use bin/new so the next app is generated with the latest rails gem.", :yellow
end

def git_repo?
  File.directory?(".git")
end

add_template_repository_to_source_path
warn_if_rails_stale!

say "Applying #{REPO_SLUG} (modules: #{requested_modules.presence || 'core only'})", :green

apply "recipes/core.rb"
apply "recipes/rspec.rb"
apply "recipes/i18n.rb"
apply "recipes/lefthook.rb"
apply "recipes/mission_control.rb"
apply "recipes/administrate.rb" if with?("administrate")
apply "recipes/caprover.rb" if with?("caprover")

after_bundle do
  say "Refreshing Gemfile.lock to the newest compatible gems", :green
  run "bundle update --all"

  apply "recipes/after_bundle.rb"

  if git_repo?
    git add: "."
    git commit: "-m 'chore: apply thematrixcrop/rails-template'"
  end
end
