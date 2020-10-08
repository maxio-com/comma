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

    def run(iterator_method, iterator_arguments = {})
      if @filename
        CSV_HANDLER.open(@filename, 'w', @options) { |csv| append_csv(csv, iterator_method, iterator_arguments) } && (return true)
      else
        CSV_HANDLER.generate(@options) { |csv| append_csv(csv, iterator_method, iterator_arguments) }
      end
    end

    private

    def append_csv(csv, iterator_method, iterator_arguments)
      return '' if @instance.empty?

      args = iterator_arguments.empty? ? [iterator_method] : [iterator_method, iterator_arguments]

      csv << @instance.first.to_comma_headers(@style, @globals) unless
        @options.key?(:write_headers) && !@options[:write_headers]
      @instance.send(*args) do |object|
        if object.is_a?(Array) # returned by find_in_batches
          object.each { |record| csv << record.to_comma(@style, @sanitized, @globals) }
        else
          csv << object.to_comma(@style, @sanitized, @globals)
        end
      end
    end
  end
end
