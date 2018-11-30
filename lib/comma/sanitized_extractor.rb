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

    # these character can cause excel to run malicious code if user clicks 'trust this'
    def starts_with_special_characters?(result)
      result.start_with?("+", "-", "=", "@")
    end

    # this is in case the result is only + and then numbers, as in the case of a phone number
    def only_numbers?(result)
      length = result.length

      result.start_with?("+") && (result.slice(1..length) !~ /\D/)
    end

    # check to see if the result is possibly just a negative number
    def starts_with_dash?(result)
      result.start_with?("-")
    end

    # check to see if result is under 6 non-numerical characters
    def under_six_non_numerical_characters?(result)
      result.scan(/\D/).size <= 6
    end

    # check to see if it is basically a negative number of some sort
    # some sort of "-$2,123,456,789.00"
    def retain_result_as_number?(result)
      starts_with_dash?(result) && under_six_non_numerical_characters?(result)
    end

    # check if it starts with a dash and contains more than 6 non-numerical chars
    def prepend_with_apostrophe?(result)
      starts_with_dash?(result) && !under_six_non_numerical_characters?(result)
    end

    def prepend_with_apostrophe(result)
      result = "'" + result
      result
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
    # only if it's more than 10 digits
    # otherwise remove and special characters at the start of the string
    # if it doesnt start with a special character, leave it alone
    def sanitize_result(result)
      result = result.to_s
      if starts_with_special_characters?(result)
        if only_numbers?(result)
          result
        elsif retain_result_as_number?(result)
          result
        elsif prepend_with_apostrophe?(result)
          prepend_with_apostrophe(result)
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
