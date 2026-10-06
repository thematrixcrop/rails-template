# frozen_string_literal: true

# Structured, redacting log lines on top of Rails.logger.
#
#   AppLog.info("billing.charge", "request", user_id: 12)
#   # => [billing.charge] request user_id=12
#
# The scope is the first token so a grep for `[billing.charge]` finds every
# line the feature wrote. Values whose key looks like a credential are
# replaced before they reach the line.
module AppLog
  REDACTED_KEY = /token|secret|password|cookie|authorization|api_key|refresh|license_key|signature|credential|\Acode\z|session_key/i
  REDACTED = "***"

  module_function

  def debug(scope, event, **fields)
    Rails.logger.debug { line(scope, event, fields) }
  end

  def info(scope, event, **fields)
    Rails.logger.info { line(scope, event, fields) }
  end

  def warn(scope, event, **fields)
    Rails.logger.warn { line(scope, event, fields) }
  end

  def error(scope, event, **fields)
    Rails.logger.error { line(scope, event, fields) }
  end

  def line(scope, event, fields)
    rendered = fields.map { |key, value| "#{key}=#{format_value(key, value)}" }
    [ "[#{scope}]", event, *rendered ].join(" ")
  end

  def format_value(key, value)
    return REDACTED if key.to_s.match?(REDACTED_KEY) && !value.nil?

    case value
    when nil then "nil"
    when Array then value.map { |member| format_value(key, member) }.join(",")
    when Exception then "#{value.class}: #{value.message}".inspect
    when String then value.match?(/\s/) ? value.inspect : value
    else value.to_s
    end
  end
end
