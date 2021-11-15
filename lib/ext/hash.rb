# frozen_string_literal: true

##
# @private
class Hash
  def deep_symbolize_keys
    each_with_object({}) do |(key, value), result|
      value       = value.deep_symbolize_keys if value.is_a? Hash
      result[begin
        key.to_sym
      rescue StandardError
        key
      end || key] = value
    end
  end

  def deep_symbolize_keys!
    self.replace(deep_camelize_keys)
  end

  def deep_stringify_keys
    each_with_object({}) do |(key, value), result|
      value       = value.deep_stringify_keys if value.is_a? Hash
      result[begin
        key.to_s
      rescue StandardError
        key
      end || key] = value
    end
  end

  def deep_camelize_keys
    each_with_object({}) do |(key, value), result|
      value       = value.deep_camelize_keys if value.is_a? Hash
      result[begin
        key.to_s.camelize
      rescue StandardError
        key
      end || key] = value
    end
  end

  # recursivly underscores keys of a hash
  def deep_underscore_keys
    each_with_object({}) do |(key, value), result|
      value       = value.deep_underscore_keys if value.is_a? Hash
      result[begin
        key.to_s.underscore
      rescue StandardError
        key
      end || key] = value
    end
  end
end
