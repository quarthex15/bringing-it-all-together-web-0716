class Dog

  attr_accessor :name, :breed, :id

  def initialize(arguments)
    @name = arguments[:name]
    @breed = arguments[:breed]
    @id = arguments[:id]
  end

  def self.create_table
    sql = 
      "CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      );"

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL 
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs
      WHERE name = ?" 

    new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def save
    if @id
      self.update
    else
      self.insert
    end
    self
  end

  def update
    sql = "UPDATE dogs
    SET name = ?, breed = ?"

    DB[:conn].execute(sql, @name, @breed)
  end

  def insert
    sql = "INSERT INTO dogs
    (name, breed) VALUES (?,?)"

    DB[:conn].execute(sql, @name, @breed)

    sql = "SELECT last_insert_rowid()"
    @id = DB[:conn].execute(sql)[0][0]
  end

  def self.create(arguments)
    new_dog = self.new(arguments)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs
    WHERE id = ?"

    new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(arguments)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"

    result = DB[:conn].execute(sql, arguments[:name], arguments[:breed])
    if result.empty?
      new_dog = self.create(arguments)
    else
      new_dog = new_from_db(result[0])
    end
  end
end



