# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppConfig do
  around do |example|
    described_class.with_overrides(mail: { from: "ops@example.com" }) { example.run }
  end

  it "reads nested credential overrides in tests" do
    expect(described_class.value(:mail, :from)).to eq("ops@example.com")
  end

  it "builds the public URL from ENV" do
    expect(described_class.app_url).to include("://")
  end
end
