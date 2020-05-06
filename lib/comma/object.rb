# frozen_string_literal: true

require 'comma/data_extractor'
require 'comma/header_extractor'
require 'comma/sanitized_data_extractor'

class Object
  class_attribute :comma_formats

  class << self
    def comma(style = :default, &block)
      (self.comma_formats ||= {})[style] = block
    end

    def inherited(subclass)
      super
      subclass.comma_formats = self.comma_formats ? self.comma_formats.dup : {}
    end
  end

  def to_comma(style = :default, sanitized = false, globals = {})
    if !sanitized
      extract_with(Comma::DataExtractor, style, globals)
    else
      extract_with(Comma::SanitizedDataExtractor, style, globals)
    end
  end

  def to_comma_headers(style = :default, globals = {})
    extract_with(Comma::HeaderExtractor, style, globals)
  end

  private

  def extract_with(extractor_class, style = :default, globals = {})
    raise_unless_style_exists(style)
    extractor_class.new(self, style, self.comma_formats, globals).results
  end

  def raise_unless_style_exists(style)
    return if self.comma_formats && self.comma_formats[style]

    raise "No comma format for class #{self.class} defined for style #{style}"
  end
end
