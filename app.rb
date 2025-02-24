require 'sinatra'
require 'securerandom'

class App < Sinatra::Base

    def db
        return @db if @db
  
        @db = SQLite3::Database.new("db/todos.sqlite")
        @db.results_as_hash = true
  
        return @db
    end

    get '/' do
        @stats = db.execute('SELECT value FROM stats')
        erb(:"index")
    end


end
