class JackpotUsers
    def self.db
        return @db if @db

        @db = SQLite3::Database.new("db/casino.sqlite")
        @db.results_as_hash = true
        @db.execute("PRAGMA foreign_keys = ON")

        return @db
    end

    def self.index()
        db.execute('SELECT * FROM jackpot_users')
    end

    def self.create(user_id, jackpot_id)
        db.execute('INSERT INTO jackpot_users (user_id, jackpot_id) VALUES (?, ?)', [user_id, jackpot_id])
    end

    def self.select_by_ids(user_id, jackpot_id)
        db.execute('SELECT * FROM jackpot_users WHERE user_id = ? AND jackpot_id = ?', [user_id, jackpot_id])
    end

    def self.select_by_jackpot_id(jackpot_id)
        db.execute('SELECT * FROM jackpot_users WHERE jackpot_id = ?', [jackpot_id])
    end
end