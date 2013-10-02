# frozen_string_literal: true

class Book
  attr_accessor :name, :description, :isbn

  def initialize(name, description, isbn)
    @name = name
    @description = description
    @isbn = isbn
  end

  comma do
    name 'Title'
    description

    isbn authority: :issuer
    isbn number_10: 'ISBN-10'
    isbn number_13: 'ISBN-13'
  end

  comma :brief do
    name
    description
  end
end

class Isbn
  attr_accessor :number_10, :number_13

  def initialize(isbn_10, isbn_13)
    @number_10 = isbn_10
    @number_13 = isbn_13
  end

  def authority
    'ISBN'
  end
end

class NestedField
  attr_accessor :name, :address, :number, :fields

  def initialize(name, address, number, fields = [])
    @name, @address, @number, @fields =  name, address, number, fields
  end

  comma do
    name
    address
    number
    collection :fields do |n_field, column, object|
      column.name  = object.name
      column.value = object.value
    end
  end
end

class Field
  attr_accessor :name, :value

  def initialize(name, value)
    @name, @value = name, value
  end
end
