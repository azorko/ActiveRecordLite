require 'byebug'
require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  
  def self.columns
    columns = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT 1
    SQL
    columns.first.map!(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}") do
        attributes[column]
      end
      define_method("#{column}=") do |val|
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    self.parse_all(rows)
  end

  def self.parse_all(results)
    all = []
    results.each do |row|
      all << self.new(row)
    end
    all
  end

  def self.find(id)
    item = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL
    self.new(item.first)
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      attr_name = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name)
      self.send("#{attr_name}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    [].tap { |result| attributes.each { |attr_name, val| result << val } }
  end

  def insert
    values = self.attribute_values
    cols = self.class.columns
    col_num = cols.size - 1
    col_names = cols[1..-1].join(',')
    question_marks = (['?'] * col_num).join(',')
    DBConnection.execute(<<-SQL, *values)
      INSERT INTO
        #{self.class.table_name}
        (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    values = self.attribute_values
    id = values.shift
    set_line = self.class.columns[1..-1].map! { |attr_name| "#{attr_name} = ?" }.join(',')
    # byebug
    DBConnection.execute(<<-SQL, *values)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = #{id}
    SQL
  end

  def save
    self.id.nil? ? self.insert : self.update
  end
end
