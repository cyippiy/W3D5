require_relative 'db_connection'
require 'active_support/inflector'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    return @columns if @columns
    arr = []
    str = 'select * FROM ' << self.table_name
    DBConnection.execute2(str)[0].each {|el| arr << el.to_sym}
    @columns = arr

  end

  def self.finalize!

    self.columns.each do |col|
      define_method(col) do
        self.attributes[col]
      end

      define_method("#{col}=") do |value|
        self.attributes[col]=value
      end

    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name=table_name
  end

  def self.table_name
    # ...
    @table_name ||= self.name.tableize
  end

  def self.all
    # ...
    parse_all(DBConnection.execute(<<-SQL)
      SELECT
      #{table_name}.*
      FROM
      #{table_name}
    SQL
    )

  end

  def self.parse_all(results)
    # ...
    results.map {|el| self.new(el)}
  end

  def self.find(id)
    # ...
    results = DBConnection.execute(<<-SQL,id)
    SELECT
    *
    FROM
    #{table_name}
    WHERE
    id = ?
    SQL
    return nil if results.empty?
    self.new(results.first)
  end

  def initialize(params = {})
    # ...
    params.each do |k,v|
      key=k.to_sym
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(key)

    send("#{key}=",v)
    end

  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    self.class.columns.map{|attr| self.send(attr) }
  end


  def insert
    # ...
    col_names = self.class.columns.count
    question_marks = "("
    col_names.times do |x|
      question_marks << "?"
      question_marks << ", " unless x == col_names-1
    end
    quesiton_marks << ")"

    #do something
    col_names

    #do more things

    DBConnection.last_insert_row_id
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
