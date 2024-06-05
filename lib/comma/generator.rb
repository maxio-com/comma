# frozen_string_literal: true

module Comma
  class Generator
    def initialize(instance, style)
      @instance = instance
      @style    = style
      @options  = {}
      @sanitized = false
      @globals = {}

      return unless @style.is_a?(Hash)

      @options                  = @style.clone
      @style                    = @options.delete(:style) || Comma::DEFAULT_OPTIONS[:style]
      @filename                 = @options.delete(:filename)
      @sanitized                = @options.delete(:sanitized) || false
      @globals                  = @options.delete(:globals) || {}
    end

    def run(iterator_method)
      if @filename
        CSV_HANDLER.open(@filename, 'w', **@options) { |csv| append_csv(csv, iterator_method) } && (return true)
      else
        CSV_HANDLER.generate(**@options) { |csv| append_csv(csv, iterator_method) }
      end
    end

    private

    def append_csv(csv, iterator_method)
      return '' if @instance.empty?

      csv << @instance.take(1).first.to_comma_headers(@style, @globals) unless
        @options.key?(:write_headers) && !@options[:write_headers]
      @instance.send(iterator_method) do |object|
        csv << object.to_comma(@style, @sanitized, @globals)
      end
    end
  end
end
