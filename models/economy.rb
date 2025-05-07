class Economy
    def self.db
        return @db if @db

        @db = SQLite3::Database.new("db/casino.sqlite")
        @db.results_as_hash = true
        @db.execute("PRAGMA foreign_keys = ON")

        return @db
    end

    def self.index()
        db.execute('SELECT * FROM economy')
    end

    def self.create(value, user_id, time)
        db.execute('INSERT INTO economy (value, user_id, time) VALUES (?, ?, ?)', [value, user_id, time])
    end

    def self.select_by_user_id(user_id)
        db.execute('SELECT * FROM economy WHERE user_id = ?', [user_id])
    end

    def self.select_by_id(id)
        db.execute('SELECT * FROM economy WHERE id = ?', [id])
    end

    def self.merge_user(user_id)
        db.execute('SELECT * FROM economy INNER JOIN users ON economy.user_id = users.id WHERE economy.user_id = ?', [user_id])
    end
end
