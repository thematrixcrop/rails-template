# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppLog do
  it "renders scope and event" do
    expect(described_class.line("billing.charge", "ok", { user_id: 12 })).to eq(
      "[billing.charge] ok user_id=12"
    )
  end

  it "redacts credential-like keys" do
    expect(described_class.line("auth", "token", { api_key: "secret-value" })).to eq(
      "[auth] token api_key=***"
    )
  end
end
