require 'pry'

require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id 
  end #initialize

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
      SQL
      DB[:conn].execute(sql)
  end #self.create_table

  def self.drop_table
    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end #self.drop_table

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students(name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end #if
  end #save

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id) 
  end #update

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save 
  end #self.create

  def self.new_from_db(row)
    #binding.pry 
    new_student = self.new(row[1], row[2], row[0])
    new_student 
  end #self.new_from_db

  def self.find_by_name(a_name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    result = DB[:conn].execute(sql, a_name)
    self.new_from_db(result[0])
  end #self.find_by_name


  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]


end #class
