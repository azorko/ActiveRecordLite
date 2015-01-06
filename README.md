###ActiveRecord Lite

ActiveRecord Lite is my version of the Ruby on Rails framework's ActiveRecord class. I have recreated the following ActiveRecord methods: all, find, insert, update, save, and where and the following associations: belongs_to, has_many, and has_one_through.

Features:

* Ruby rendition of ORM functionality used for storing in-memory object data in relational databases

* Uses metaprogramming to create accessor methods to database table columns

* Applies modules to compartmentalize specific functionalities of ActiveRecord and mixes the modules into the overarching class
