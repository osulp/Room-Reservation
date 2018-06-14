RoomReservation::Application.routes.draw do
  root :to => 'home#index'
  get "/(day/:date)", :to => "home#index", :date => /[TZtz0-9:\-\.%]+?/, :format => /html|json/, :as => 'day'
  get "/home/day/:date", :to => "home#day", :date => /[TZtz0-9:\-\.%]+?/, :format => /html|json/
  get "/home/timebars/:date", :to => "home#timebars", :date => /[TZtz0-9:\-\.%]+?/, :format => /html|json/
  get "/login", :to => 'sessions#new'
  get "/logout", :to => 'sessions#logout'
  get "/reservations", :to => 'reservations#index', :as => :my_reservations, :format => 'html'
  get "/reservations", :to => 'reservations#current_user_reservations', :as => :current_user_reservations, :format => 'json'
  get "/availability/all/:start", :to => 'reservations#all_availability', :start => /[TZtz0-9:\-\.%]+?/, :format => /html|json/, :as => :all_availability
  get "/availability/:room_id/:start", :to => 'reservations#availability', :start => /[TZtz0-9:\-\.%]+?/, :format => /html|json/, :as => :availability
  resources :reservations, :only => [:create, :update, :destroy, :show] do
    collection do
      get 'upcoming'
    end
  end
  resources :rooms, :only => [] do
    collection do
      get 'free_times'
    end
  end
  resources :users, :only => [:show]

  get "/admin", :to => 'admin#index'

  # admin panel access
  namespace :admin do
    resources :roles, :only => [:index, :new, :create, :update, :destroy]
    resources :rooms, :only => [:index, :new, :create, :edit, :update, :destroy]
    resources :filters, :only => [:index, :new, :create, :edit, :update, :destroy]
    resources :cleaning_records
    resources :room_hours
    resources :logs, :only => [:index]
    resources :key_cards, :only => [:index, :new, :create, :edit, :update, :destroy] do
      collection do
        post 'checkin/:key', :to => 'key_cards#checkin'
      end
    end
    resources :reservations, :only => [] do
      member do
        post 'checkout/:key', :to => 'reservations#checkout'
        get 'history'
      end
    end
    resources :users, :only => [] do
      resources :reservations, :only => [:index]
    end
    resources :settings, :only => [:index, :update]
    resources :auto_logins
    post "/patron_mode/:enable", :to => "patron_mode#enable"
    get "/patron_mode", :to => "patron_mode#status"
  end
end
