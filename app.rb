require 'sinatra'
require 'securerandom'
require 'bcrypt'
require 'rack-flash'
require 'sinatra/activerecord'
require 'json'
require 'time'

class App < Sinatra::Base

    configure do
        enable :sessions
        set :session_secret, SecureRandom.hex(64)
        use Rack::Flash
    end

    def db
        return @db if @db
  
        @db = SQLite3::Database.new("db/todos.sqlite")
        @db.results_as_hash = true
  
        return @db
    end

    get '/' do
        redirect '/login'
    end
    get '/slot' do
        if session[:user]
            @stats = db.execute('SELECT value FROM stats')
            @balance = session[:user]['balance']
            @history = db.execute('SELECT value FROM economy WHERE user_id = ?', [session[:user]['id']])
            p @history
            erb(:"index")
        else 
            redirect('/login')
        end
    end
    get '/account/:id' do |id|
        if session[:user]
            @history = db.execute('SELECT * FROM economy WHERE user_id = ?', [id])
            erb(:"account")
        else 
            redirect('/login')
        end
    end
    get '/login' do
        if !session[:user]
            erb(:login)
        else
            redirect('/slot')
        end
    end
    post '/login' do
        user = db.execute('SELECT * FROM users WHERE username = ?', [params[:username]]).first

        if user && BCrypt::Password.new(user['password']) == params[:password]
            session[:user] = user
        else 
            status 401
            flash[:error] = 'Fel användarnamn eller lösenord'
        end
        redirect('/login')
    end
    get '/register' do
        erb(:register)
    end
    post '/register' do
        users = db.execute('SELECT * FROM users WHERE username = ?', [params[:username]])
        if users.empty?
            password = BCrypt::Password.create(params[:password])
            db.execute('INSERT INTO users (username, password, balance) VALUES (?, ?, 1000)', [params[:username], password])
            redirect('/login')
        else
            redirect('/register')
        end
    end
    get '/logout' do
        session[:user] = nil
        redirect('/login')
    end
    post '/updatebalance' do
        content_type :json
      
        request_payload = JSON.parse(request.body.read) # Read the JSON request body
        user = db.execute('SELECT * FROM users WHERE id = ?', [session[:user]["id"]]).first
        balance = user['balance'] + request_payload["win"] - request_payload["bet"]
        history = request_payload["win"] - request_payload["bet"]
        if user
            db.execute('UPDATE users SET balance = ? WHERE id = ?', [balance, session[:user]["id"]])
            db.execute('INSERT INTO economy (value, user_id, time) VALUES (?, ?, ?)', [history, session[:user]["id"] , Time.now.to_s])
          { success: true, message: "Balance updated", balance: balance }.to_json
        else
          { success: false, message: "User not found" }.to_json
        end
    end
    post '/stats/update' do
        value1 = params["odds1"].to_i
        value2 = value1 + params["odds2"].to_i
        value3= value2 + params["odds3"].to_i
        value4 = value3 + params["odds4"].to_i
        value5 = value4 + params["odds5"].to_i
        value6 = value5 + params["odds6"].to_i
        db.execute('UPDATE stats SET value = ? WHERE id = ?', [value1, 1])
        db.execute('UPDATE stats SET value = ? WHERE id = ?', [value2 , 2])
        db.execute('UPDATE stats SET value = ? WHERE id = ?', [value3, 3])
        db.execute('UPDATE stats SET value = ? WHERE id = ?', [value4, 4])
        db.execute('UPDATE stats SET value = ? WHERE id = ?', [value5, 5])
        db.execute('UPDATE stats SET value = ? WHERE id = ?', [value6, 6])
        redirect('/slot')
    end
end
  
