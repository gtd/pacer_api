# frozen_string_literal: true

require "active_support/inflector"

module PacerApi
  class RequestTranslator
    def self.translate(obj)
      new.translate(obj)
    end

    def translate(obj)
      case obj
      when Array then translate_array(obj)
      when Date  then translate_date(obj)
      when Hash  then translate_hash(obj)
      else            obj
      end
    end

  private

    def translate_array(array)
      array.map { |e| translate(e) }
    end

    def translate_date(date)
      date.strftime("%Y-%m-%d")
    end

    def translate_hash(hash)
      hash.map { |k, v| [translate_key(k), translate(v)] }.to_h
    end

    def translate_key(sym)
      ActiveSupport::Inflector.camelize(sym, false)
    end
  end
end
