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

    get '/' do
        redirect '/login'
    end
    get '/slot' do
        if session[:user]
            @balance = session[:user]['balance']
            @jackpots = Jackpots.index()
            p @history
            erb(:"hell/index")
        else 
            redirect('/login')
        end
    end
    get '/economies' do
        if session[:user]
            id = session[:user]["id"]
            @total = 0
            @history = Economy.merge_user(id)
            for i in 0..@history.length-1
                @total += @history[i]["value"]
            end
            erb(:"/economies/index")
        else 
            redirect('/login')
        end
    end
    get '/login' do
        if !session[:user]
            erb(:"sessions/index")
        else
            redirect('/slot')
        end
    end
    post '/login' do
        user = Users.select_by_username(params[:username]).first
        
        session[:login_attempts] ||= 0
        session[:time_since_last_attempt] ||= Time.now
        if session[:login_attempts] >= 3 && Time.now - session[:time_since_last_attempt] < 60
            flash[:error] = 'För många inloggningsförsök. Försök igen om 60 sekunder.'
            redirect('/login')
        else 
            session[:time_since_last_attempt] = Time.now
        end
        if user && BCrypt::Password.new(user['password']) == params[:password]
            session[:user] = user
            session[:login_attempts] = 0
        else 
            status 401
            flash[:error] = 'Fel användarnamn eller lösenord'
            session[:login_attempts] += 1
        end
        redirect('/login')
    end
    get '/users/new' do
        erb(:"users/new")
    end
    post '/users' do
        users = Users.select_by_username(params[:username])
        if users.empty?
            Users.create(params[:username], params[:password])
            redirect('/login')
        else
            redirect('/users/new')
        end
    end
    post '/logout' do
        session[:user] = nil
        redirect('/login')
    end
    post '/users/update_spin' do
        content_type :json
      
        request_payload = JSON.parse(request.body.read) # Read the JSON request body
        user = Users.select_by_id(session[:user]["id"])
        balance = user['balance'] + request_payload["win"] - request_payload["bet"]
        history = request_payload["win"] - request_payload["bet"]
        if user && user['balance'] >= 20
            Users.update_balance(user["id"], balance)
            Economy.create(history, user["id"], Time.now.strftime("%Y-%d-%m %H:%M:%S"))
          { success: true, message: "Balance updated", balance: balance }.to_json
        else
          { success: false, message: "User not found" }.to_json
        end
    end
    post '/stats/update' do
        i = 1
        content = true
        odd_total = 0
        if session[:user]["admin"] == 1
            while content
                if params["odds#{i}"]
                    Stats.update_value(params["odds#{i}"].to_i + odd_total, i)
                    odd_total += params["odds#{i}"].to_i
                else
                    content = false
                end
                i += 1
            end
        end 
        redirect('/slot')
    end
    post '/jackpots/create' do
        p(session[:user])
        if session[:user]["admin"] == 1
            p(params)
            Jackpots.create(params["name"], params["value"].to_i, params["price"].to_i)
            p(Jackpots.index().last)
        end
        redirect('/slot')
    end
    post '/jackpot_users' do
        if session[:user]
            id = params["jackpot_id"].to_i
            jackpot = Jackpots.select_by_id(id)
            jackpot_users = JackpotUsers.select_by_ids(session[:user]["id"], id).first
            p(jackpot_users)
            if jackpot
                if !jackpot_users
                    if session[:user]["balance"] >= jackpot["price"]
                        Users.update_balance(session[:user]["id"], session[:user]["balance"] - jackpot["price"])
                        Economy.create(jackpot["price"], session[:user]["id"], Time.now.strftime("%Y-%d-%m %H:%M:%S"))
                        JackpotUsers.create(session[:user]["id"], id)
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
    get '/jackpots' do
        content_type :json
        jackpot_list = [];
        jackpot_array = [];
        jackpots = Jackpots.index()
        jackpot_users = JackpotUsers.index()
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
    get '/stats' do
        content_type :json
        stats = Stats.index()
        stats_array = []
        for stat in stats
            stats_array.append(stat["value"])
        end
        {success: true, message: "Stats fetched", stats: stats_array}.to_json
    end
    post '/users/update' do
        if session[:user]
            Users.update_balance(session[:user]["id"], session[:user]["balance"].to_i + params["depositAmount"].to_i)
        end
        redirect('/slot')
    end
    post '/users/:id/delete' do |id|
        if session[:user]["id"] == id.to_i
            Users.delete(id)
            session[:user] = nil
        end
        redirect('/login')
    end
    post '/jackpots/:id/delete' do |id|
        if session[:user]["admin"] == 1
            jackpot = Jackpots.select_by_id(id)
            player_amount = JackpotUsers.select_by_jackpot_id(id).length
            if jackpot
                JackpotUsers.select_by_jackpot_id(id).each do |user|
                    Users.update_balance(user["user_id"], Users.select_by_id(user["user_id"])["balance"] + (jackpot["value"] / player_amount))
                    Economy.create((jackpot["value"] / player_amount), user["user_id"], Time.now.strftime("%Y-%d-%m %H:%M:%S"))
                end
                Jackpots.delete(id)
            end
        end
        redirect('/slot')
    end 

end
  
 