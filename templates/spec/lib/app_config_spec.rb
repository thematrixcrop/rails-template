# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppConfig do
  it "does not read the real credentials file in the test environment" do
    expect(described_class.credential(:mission_control, :http_basic_auth_user)).to be_nil
  end

  describe ".credential" do
    around do |example|
      described_class.with_overrides(google: { client_id: "id.apps.googleusercontent.com" }) { example.run }
    end

    it "reads nested credential overrides in tests" do
      expect(described_class.credential(:google, :client_id)).to eq("id.apps.googleusercontent.com")
    end

    it "returns nil when a key is missing" do
      expect(described_class.credential(:google, :client_secret)).to be_nil
    end
  end

  describe "ENV" do
    it "builds the public URL from APP_HOST" do
      expect(described_class.app_url).to include("://")
    end

    it "reads APP_HOST from the environment" do
      previous = ENV["APP_HOST"]
      ENV["APP_HOST"] = "example.test:3000"
      expect(described_class.app_host).to eq("example.test:3000")
    ensure
      if previous
        ENV["APP_HOST"] = previous
      else
        ENV.delete("APP_HOST")
      end
    end
  end
end
