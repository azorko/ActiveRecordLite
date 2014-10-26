require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    where_line = params.keys.map! { |attr_name| "#{attr_name} = ?" }.join(' AND ')
    values = params.values.map!(&:to_s)
    results = DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    results.map! { |result| self.new(result) }
  end
end

class SQLObject
  extend Searchable
end
