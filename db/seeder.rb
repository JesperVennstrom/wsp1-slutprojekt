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
    db.execute('DROP TABLE IF EXISTS economy')
    db.execute('DROP TABLE IF EXISTS jackpots')
    db.execute('DROP TABLE IF EXISTS jackpot_users')
  end

  def self.create_tables
  
    db.execute('CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      balance INTEGER DEFAULT 0,
      admin BOOLEAN DEFAULT FALSE
    )')
    db.execute('CREATE TABLE stats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      value INTEGER NOT NULL
    )')
    db.execute('CREATE TABLE economy (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      value INTEGER NOT NULL,
      user_id INTEGER NOT NULL, 
      time STRING NOT NULL
    )')
    db.execute('CREATE TABLE jackpots (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      value INTEGER NOT NULL,
      price INTEGER DEFAULT 0
    )')
    db.execute('CREATE TABLE jackpot_users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      jackpot_id INTEGER NOT NULL
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
    db.execute('INSERT INTO stats (name, value) VALUES ("odd6", 900)')

    db.execute('INSERT INTO jackpots (name, value, price) VALUES ("jackpot1", 100000, 10)')
    db.execute('INSERT INTO jackpots (name, value, price) VALUES ("jackpot2", 200000, 20)')
    db.execute('INSERT INTO jackpots (name, value, price) VALUES ("jackpot3", 300000, 30)')
  end 

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/casino.sqlite')
    @db.results_as_hash = true
    @db
  end

end

Seeder.seed!
