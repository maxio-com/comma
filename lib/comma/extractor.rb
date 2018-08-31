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

    def sanitize_result(result)
      while result.start_with?("+", "-", "=", "@")
        result.slice!(0)
      end
    end

    def convert_to_data_value(result)
      if result.nil?
        result
      else
        sanitize_result(result.to_s)
        result
      end
    end
  end
  
end
