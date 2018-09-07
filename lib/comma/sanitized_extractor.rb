# -*- coding: utf-8 -*-

module Comma

  class SanitizedExtractor

    def check_for_only_digits(result)
      length = result.length

      result.start_with?("+") && (result.slice(1..length) !~ /\D/)
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
        if check_for_only_digits(result)
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

    def convert_to_data_value(result)
      result.nil? ? result : result.to_s
    end

end
