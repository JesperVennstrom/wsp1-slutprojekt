require 'sinatra'
require 'securerandom'
require 'bcrypt'
require 'rack-flash'
require 'sinatra/activerecord'
require 'json'
require 'time'

require_relative 'models/users'
require_relative 'models/jackpots'
require_relative 'models/jackpot_users'
require_relative 'models/economy'
require_relative 'models/stats'

class App < Sinatra::Base

    configure do
        enable :sessions
        set :session_secret, SecureRandom.hex(64)
        use Rack::Flash
    end

    def db
        return @db if @db
  
        @db = SQLite3::Database.new("db/casino.sqlite")
        @db.results_as_hash = true
  
        return @db
    end

    get '/' do
        redirect '/login'
    end
    get '/slot' do
        if session[:user]
            @balance = session[:user]['balance']
            @jackpots = Jackpots.index()
            p @history
            erb(:"index")
        else 
            redirect('/login')
        end
    end
    get '/account/:id' do |id|
        if session[:user]
            @total = 0
            @history = Economy.select_by_user_id(session[:user]["id"])
            for i in 0..@history.length-1
                @total += @history[i]["value"]
            end
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
        user = Users.select_by_username(params[:username]).first

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
        users = Users.select_by_username(params[:username])
        if users.empty?
            Users.create(params[:username], params[:password])
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
        user = Users.select_by_id(session[:user]["id"])
        balance = user['balance'] + request_payload["win"] - request_payload["bet"]
        history = request_payload["win"] - request_payload["bet"]
        if user && user['balance'] >= 20
            Users.update_balance(session[:user]["id"], balance)
            Economy.create(history, session[:user]["id"], Time.now.strftime("%Y-%d-%m %H:%M:%S"))
          { success: true, message: "Balance updated", balance: balance }.to_json
        else
          { success: false, message: "User not found" }.to_json
        end
    end
    post '/stats/update' do
        i = 1
        content = true
        odd_total = 0
        while content
            if params["odds#{i}"]
                p("hello2")
                Stats.update_value(params["odds#{i}"].to_i + odd_total, i)
                odd_total += params["odds#{i}"].to_i
            else
                content = false
            end
            i += 1
        end
        redirect('/slot')
    end
    post '/jackpot/:id' do |id|
        if session[:user]
            p(id)
            jackpot = Jackpots.select_by_id(id)
            p(jackpot)
            jackpot_users = db.execute('SELECT * FROM jackpot_users WHERE user_id = ? AND jackpot_id = ?', [session[:user]["id"], id]).first
            if jackpot
                if !jackpot_users
                    if session[:user]["balance"] >= jackpot["price"]
                        Users.update_balance(session[:user]["id"], session[:user]["balance"] - jackpot["price"])
                        Economy.create(jackpot["price"], session[:user]["id"], Time.now.strftime("%Y-%d-%m %H:%M:%S"))
                        db.execute('INSERT INTO jackpot_users (user_id, jackpot_id) VALUES (?, ?)', [session[:user]["id"], id])
                        jackpot_add = jackpot["price"] / 10
                        Jackpots.update_value((jackpot["value"] + jackpot_add), id)
                    end
                end
            end
            redirect('/slot')
        else
            redirect('/login')
        end
    end
    get '/getjackpot' do
        content_type :json
        jackpot_list = [];
        jackpot_array = [];
        jackpots = Jackpots.index()
        jackpot_users = db.execute('SELECT * FROM jackpot_users')
        for jackpot in jackpot_users
            if jackpot["user_id"] == session[:user]["id"]
                jackpot_list.append(jackpot["jackpot_id"])
            end
        end
        for jackpot in jackpots
            for i in 0..jackpot_list.length-1
                if jackpot["id"] == jackpot_list[i]
                    weight = 1000000 / jackpot["value"]
                    jackpot_array.append([jackpot["name"], jackpot["value"], weight])
                end
            end
        end
        jackpot_array.to_json
        
        {success: true, message: "Jackpots fetched", jackpots: jackpot_array}.to_json
    end
    get '/getodds' do
        content_type :json
        stats = Stats.index()
        stats_array = []
        for stat in stats
            stats_array.append(stat["value"])
        end
        {success: true, message: "Stats fetched", stats: stats_array}.to_json
    end
    post '/deposit' do
        if session[:user]
            Users.update_balance(session[:user]["id"], session[:user]["balance"] + params["depositAmount"])
        end
        redirect('/slot')
    end
end
  
