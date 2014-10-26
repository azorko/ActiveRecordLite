require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name || @class_name.tableize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name = options[:class_name] ||= "#{name.to_s.camelcase}"
    @foreign_key = options[:foreign_key] ||= "#{name.to_s}_id".to_sym
    @primary_key = options[:primary_key] ||= :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] ||= "#{name.to_s.singularize.camelcase}"
    @foreign_key = options[:foreign_key] ||= "#{self_class_name.to_s.underscore}_id".to_sym
    @primary_key = options[:primary_key] ||= :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    assoc_options[name.to_sym] = BelongsToOptions.new(name, options)
    options = BelongsToOptions.new(name, options)
    define_method("#{name}") do
      foreign_key = send(options.foreign_key)
      model_class = options.model_class
      primary_key = options.primary_key.to_sym
      model_class.where({primary_key  => foreign_key}).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method("#{name}") do
      model_class = options.model_class
      foreign_key = options.foreign_key
      primary_key = attributes[options.primary_key.to_sym]
      model_class.where({foreign_key => primary_key})
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
