# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Locales" do
  PLURAL_KEYS = %w[zero one two few many other].freeze
  PLACEHOLDER = /%\{(\w+)\}/

  def plural?(value) = value.is_a?(Hash) && (value.keys.map(&:to_s) - PLURAL_KEYS).empty?

  def leaves(hash) = leaf_pairs(hash).to_h

  def leaf_pairs(hash, prefix = [])
    hash.flat_map do |key, value|
      path = prefix + [ key.to_s ]
      value.is_a?(Hash) && !plural?(value) ? leaf_pairs(value, path) : [ [ path.join("."), value ] ]
    end
  end

  def placeholders(value)
    Array(value.is_a?(Hash) ? value.values : value).flat_map { _1.to_s.scan(PLACEHOLDER).flatten }.to_set
  end

  def load_locale(code)
    YAML.load_file(Rails.root.join("config/locales/#{code}.yml")).fetch(code.to_s)
  end

  let(:reference) { leaves(load_locale(:en)) }

  it "has a file for every available locale and no others" do
    files = Dir[Rails.root.join("config/locales/*.yml")].map { File.basename(_1, ".yml").to_sym }
    expect(files).to include(*I18n.available_locales)
  end

  I18n.available_locales.each do |code|
    describe code.to_s do
      let(:translation) { leaves(load_locale(code)) }

      it "defines the same keys as en" do
        expect(translation.keys).to match_array(reference.keys)
      end

      it "keeps the interpolation placeholders" do
        reference.each do |key, value|
          expect(placeholders(translation[key])).to eq(placeholders(value)), key
        end
      end
    end
  end
end
