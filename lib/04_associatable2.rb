require_relative '03_associatable'

# Phase IV
module Associatable

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]
    
    define_method("#{name}") do 
      source_options = through_options.model_class.assoc_options[source_name]
      table1 = source_options.model_class.table_name
      table2 = through_options.model_class.table_name
      fk = source_options.foreign_key
      join_on = "#{table1} ON #{table2}.#{fk} = #{table1}.id"
      where_line = "#{table2}.id = #{self.attributes[through_options.foreign_key]}"
      results = DBConnection.execute(<<-SQL)
        SELECT
          #{table1}.*
        FROM
          #{table2}
        JOIN
          #{join_on} 
        WHERE
          #{where_line}
      SQL
      source_options.model_class.new(results.first)
      
    end
  end
end
