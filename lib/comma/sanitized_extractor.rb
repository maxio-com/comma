# -*- coding: utf-8 -*-

module Comma

  class SanitizedExtractor < Extractor

    def initialize(instance, style, formats)
      @instance = instance
      @style = style
      @formats = formats
      @results = []
    end

    def results
      instance_eval &@formats[@style]
      @results.map { |r| convert_to_data_value(r) }
    end

    def id(*args, &block)
      method_missing(:id, *args, &block)
    end

    def __use__(style)
      # TODO: prevent infinite recursion
      instance_eval(&@formats[style])
    end

    private

    def check_for_only_digits(result)
      length = result.length

      result.start_with?("+") && (result.slice(1..length) !~ /\D/)
    end

    def check_for_decimal_values(result)
      decimal_values = /^-?(0|[1-9]\d*)?(\.\d+)?(?<=\d)$/
      (result =~ decimal_values).present?
    end

    def remove_special_characters_at_start(result)
      while starts_with_special_characters(result)
        result.slice!(0)
      end
      result
    end

    def starts_with_special_characters(result)
      result.start_with?("+", "-", "=", "@")
    end

    def sanitize_result(result)
      result = result.to_s
      if starts_with_special_characters(result)
        if check_for_only_digits(result) || check_for_decimal_values(result)
          result
        else
          remove_special_characters_at_start(result)
        end
      else
        result
      end
    end

    def convert_to_data_value(result)
      if result.nil?
        result
      else
        sanitize_result(result)
      end
    end
  end
end
