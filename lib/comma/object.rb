# -*- coding: utf-8 -*-
require 'comma/data_extractor'
require 'comma/header_extractor'
require 'comma/sanitized_data_extractor'

class Object
  class_attribute :comma_formats

  def self.comma(style = :default, &block)
    (self.comma_formats ||= {})[style] = block
  end

  def to_comma(style = :default, sanitize = false)
    unless sanitize
      extract_with(Comma::DataExtractor, style)
    else
      extract_with(Comma::SanitizedDataExtractor, style)
    end
  end

  def to_comma_headers(style = :default)
    extract_with(Comma::HeaderExtractor, style)
  end

  private

  def extract_with(extractor_class, style = :default)
    raise_unless_style_exists(style)
    extractor_class.new(self, style, self.class.comma_formats).results
  end

  def raise_unless_style_exists(style)
    raise "No comma format for class #{self.class} defined for style #{style}" unless self.comma_formats && self.comma_formats[style]
  end
end
