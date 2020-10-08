# frozen_string_literal: true

module ActiveRecord
  class Relation
    def to_comma(style = :default)
      iterator_args = {}
      iterator_method =
        if arel.ast.limit
          Rails.logger.warn { <<~WARN } if defined?(Rails)
            #to_comma is being used on a relation with limit or order clauses. Falling back to iterating with :each. This can cause performance issues.
          WARN
          :each
        elsif !arel.ast.orders.empty? && arel.ast.orders.size == 1
          property_key, direction = arel.ast.orders[0].split(" ")
          iterator_args = {property_key: property_key, direction: direction}
          :find_in_batches_with_order
        else
          :find_each
        end
      Comma::Generator.new(self, style).run(iterator_method, iterator_args)
    end
  end
end
