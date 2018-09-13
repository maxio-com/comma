# -*- coding: utf-8 -*-
require 'comma/extractor'

module Comma

  class DataExtractor < Extractor

    class ExtractValueFromInstance
      def initialize(instance)
        binding.pry
        @instance = instance
      end

      def extract(sym, &block)
        yield_block_with_value(extract_value(sym), &block)
      end

      private

      def yield_block_with_value(value, &block)
        block ? yield(value) : value
      end

      def extract_value(method)
        value = extraction_object.send(method).to_s

        if starts_with_special_characters(value)
          if check_for_only_digits(value)
            value
          else
            remove_special_characters_at_start(value)
          end
        else
          value
        end
      end

      def extraction_object
        @instance
      end

      def check_for_only_digits(value)
        length = value.length
        result.start_with?("+") && (result.slice(1..length) !~ /\D/)
      end

      def starts_with_special_characters(value)
        value.start_with?("+", "-", "=", "@")
      end

      def remove_special_characters_at_start(value)
        while starts_with_special_characters(value)
          value.slice!(0)
        end
        value
      end

    end

    class ExtractValueFromAssociationOfInstance < ExtractValueFromInstance
      def initialize(instance, association_name)
        super(instance)
        @association_name = association_name
      end

      private

      def extraction_object
        @instance.send(@association_name) || null_association
      end

      def null_association
        @null_association ||= Class.new(Class.const_defined?(:BasicObject) ? ::BasicObject : ::Object) do
          def method_missing(symbol, *args, &block)
            nil
          end
        end.new
      end
    end

    def method_missing(sym, *args, &block)
      if args.blank?
        @results << ExtractValueFromInstance.new(@instance).extract(sym, &block)
      end

      args.each do |arg|
        case arg
        when Hash
          arg.each do |k, v|
            @results << ExtractValueFromAssociationOfInstance.new(@instance, sym).extract(k, &block)
          end
        when Symbol
          @results << ExtractValueFromAssociationOfInstance.new(@instance, sym).extract(arg, &block)
        when String
          @results << ExtractValueFromInstance.new(@instance).extract(sym, &block)
        else
          raise "Unknown data symbol #{arg.inspect}"
        end
      end
    end

    def __static_column__(header = nil, &block)
      @results << (block ? yield(@instance) : nil)
    end
  end
end
