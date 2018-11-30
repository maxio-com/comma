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
    def result_only_numbers?(result)
      length = result.length

      result.start_with?("+") && (result.slice(1..length) !~ /\D/)
    end

    def starts_with_dash?(result)
      result.start_with?("-")
    end

    # results would then transform from "+astring" to "'+astring"
    def prepend_result_with_apostrophe(result)
      result = "'" + result
      result
    end

    # these character can cause excel to run malicious code if user clicks 'trust this'
    def starts_with_special_characters?(result)
      result.start_with?("+", "-", "=", "@")
    end

    def remove_special_characters_at_start(result)
      while starts_with_special_characters(result)
        result.slice!(0)
      end
      result
    end

    # sanitize the result in the following way:
    # if it starts with a special character, do some additional checking
    # if the result is a "+" and then only numbers, return it
    # otherwise if it starts with a dash (ex. "-5.0") prepend an apostrophe
    # otherwise remove and special characters at the start of the string
    # if it doesnt start with a special character, leave it alone
    def sanitize_result(result)
      result = result.to_s
      if starts_with_special_characters?(result)
        if result_only_numbers?(result)
          result
        elsif starts_with_dash?(result)
          prepend_result_with_apostrophe(result)
        else
          remove_special_characters_at_start(result)
        end
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
