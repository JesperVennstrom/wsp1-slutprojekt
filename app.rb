require 'sinatra'
require 'securerandom'
require 'bcrypt'
require 'rack-flash'
require 'sinatra/activerecord'
require 'json'

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
            erb(:"index")
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
    post '/logout' do
        session[:user] = nil
        redirect('/login')
    end

end
put '/updateBalance' do
    content_type :json
    p("hello")
    user = User.find_by(id: params[:id]) #??
    if user 
        request_payload = JSON.parse(request.body.read)
        user.update(balance: request_payload["balance"])
        { success: true, message: "Balance updated", user: user }.to_json
    else
        { success: false, message: "User not found" }.to_json
    end
end
