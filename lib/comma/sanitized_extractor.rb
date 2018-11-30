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

    # this is in case the result is only + and then numbers, as in the case of a phone number
    def check_for_only_digits(result)
      length = result.length

      result.start_with?("+") && (result.slice(1..length) !~ /\D/)
    end

    # results would then transform from "+astring" to "'+astring"
    def append_result_with_apostrophe(result)
      result = "'" + result
      result
    end

    # these character can cause excel to run malicious code if user clicks 'trust this'
    def starts_with_special_characters(result)
      result.start_with?("+", "-", "=", "@")
    end

    # if the result begins with a bad character, prepend apostrophe, otherwise return it
    def sanitize_result(result)
      result = result.to_s
      if starts_with_special_characters(result)
        append_result_with_apostrophe(result)
      else
        result
      end
    end

    # sanitize the result unless it's nil
    def convert_to_data_value(result)
      if result.nil?
        result
      else
        sanitize_result(result)
      end
    end
  end
end
