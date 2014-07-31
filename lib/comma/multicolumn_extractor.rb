require "ostruct"

module Comma
  class MulticolumnExtractor
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
      [].tap do |output|
        objects = instance.send(method)
        [objects].flatten.compact.each do |object|
          memo   = Array.new
          block.yield memo, object
          memo.each{|m| output << OpenStruct.new(m) }
        end
      end
    end
  end
end
