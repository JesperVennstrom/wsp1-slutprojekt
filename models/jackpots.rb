class Jackpots
    def self.db
        return @db if @db

        @db = SQLite3::Database.new("db/casino.sqlite")
        @db.results_as_hash = true

        return @db
    end

    def self.index()
        db.execute('SELECT * FROM jackpots')
    end

    def self.create(name, value, price)
        db.execute('INSERT INTO jackpots (name, value, price) VALUES (?, ?, ?)', [name, value, price])
    end

    def self.select_by_id(id)
        db.execute('SELECT * FROM jackpots WHERE id = ?', [id]).first
    end

    def self.update_value(value, id)
        db.execute('UPDATE jackpots SET value = ? WHERE id = ?', [value, id])
    end
end