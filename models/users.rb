class Users
    def self.db
        return @db if @db
  
        @db = SQLite3::Database.new("db/casino.sqlite")
        @db.results_as_hash = true
  
        return @db
    end
    def self.create(username, password)
        password = BCrypt::Password.create(password)
        db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [username, password])
    end

    def self.update_balance(id, balance)
        db.execute('UPDATE users SET balance = ? WHERE id = ?', [balance, id])
    end

    def self.select_by_username(username)
        db.execute('SELECT * FROM users WHERE username = ?', [username])
    end

    def self.select_by_id(id)
        db.execute('SELECT * FROM users WHERE id = ?', [id]).first
    end
end