# frozen_string_literal: true

require "time"
require "active_support/inflector"

module PacerApi
  class ResponseTranslator
    def self.translate(obj)
      new.translate(obj)
    end

    def translate(obj)
      case obj
      when Array  then translate_array(obj)
      when Date   then translate_date(obj)
      when Hash   then translate_hash(obj)
      when String then translate_string(obj)
      else             obj
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

    def translate_key(str)
      ActiveSupport::Inflector.underscore(str).to_sym
    end

    def translate_string(str)
      case str
      when /\A\d{4}-\d{2}-\d{2}\z/
        Date.parse(str)
      when /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/
        Time.parse(str)
      else
        str
      end
    end
  end
end
