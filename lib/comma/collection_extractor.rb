require "ostruct"

module Comma
  class CollectionExtractor
    attr_accessor :instance, :method, :block

    def initialize(instance, method, &block)
      @instance, @method, @block = instance, method, block
    end

    def extract_header
      cached_results.map(&:name)
    end

    def extract_values
      cached_results.map(&:value)
    end

    private
    def cached_results
      @cached_results ||= build_results
    end

    def build_results
      [].tap do |a|
        objects = instance.send(method)
        [objects].flatten.compact.each do |object|
          column = OpenStruct.new(:name => nil, :value => nil)
          block.yield instance, column, object
          a << column
        end
      end
    end
  end
end
