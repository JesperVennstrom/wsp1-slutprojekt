require 'sqlite3'
require 'bcrypt'

class Seeder

  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS stats')
    
  
  end
  def self.create_tables
  
    db.execute('CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      balance INTEGER,
      admin BOOLEAN DEFAULT FALSE
    )')
    db.execute('CREATE TABLE stats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      value INTEGER NOT NULL
    )')
  end
  def self.populate_tables 
    bcrypt_password = BCrypt::Password.create('admin')
    db.execute('INSERT INTO users (username, password, balance, admin) VALUES ("admin", ?, 1000, true)', [bcrypt_password])
    bcrypt_password1 = BCrypt::Password.create('user')
    db.execute('INSERT INTO users (username, password, balance) VALUES ("user", ?, 1000)', [bcrypt_password1])

    db.execute('INSERT INTO stats (name, value) VALUES ("odd1", 250)')
    db.execute('INSERT INTO stats (name, value) VALUES ("odd2", 450)')
    db.execute('INSERT INTO stats (name, value) VALUES ("odd3", 600)')
    db.execute('INSERT INTO stats (name, value) VALUES ("odd4", 725)')
    db.execute('INSERT INTO stats (name, value) VALUES ("odd5", 825)')
    db.execute('INSERT INTO stats (name, value) VALUES ("wild", 900)')
  end 

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/todos.sqlite')
    @db.results_as_hash = true
    @db
  end

end

Seeder.seed!
