require 'pry'

require_relative "../config/environment.rb"

# Remember, you can access your database connection anywhere in this class
# with DB[:conn]

class Student

  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id, @name, @grade = id, name, grade
  end

  def self.create_by_data_row(row)
    Student.new(row[0],row[1],row[2])
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students(
      id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    create_by_data_row(row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
      LIMIT 1
    SQL
    row = DB[:conn].execute(sql, name)[0]
    create_by_data_row(row)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end


end
