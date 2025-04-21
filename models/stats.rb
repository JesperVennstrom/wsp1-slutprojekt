class Stats
    def self.db
        return @db if @db

        @db = SQLite3::Database.new("db/casino.sqlite")
        @db.results_as_hash = true
        @db.execute("PRAGMA foreign_keys = ON")

        return @db
    end

    def self.index()
        db.execute('SELECT * FROM stats')
    end

    def self.update_value(value, id)
        db.execute('UPDATE stats SET value = ? WHERE id = ?', [value, id])
    end
end