# -*- coding: utf-8 -*-

module Comma

  class Extractor

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

    def append_apostrophe(result)
      result = "'" + result
    end

    def sanitize_result(result)
      result = result.to_s
      if result.start_with?("+", "-", "=", "@")
        if check_for_only_digits(result)
          result
        else
          append_apostrophe(result)
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
