require_relative 'collection_extractor'

module Comma
  class MultiCollectionExtractor < CollectionExtractor
    private
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
