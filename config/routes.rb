RoomReservation::Application.routes.draw do
  root :to => 'home#index'
  get "/(day/:date)", :to => "home#index", :date => /[TZtz0-9:\-\.%]+?/, :format => /html|json/
  get "/home/day/:date", :to => "home#day", :date => /[TZtz0-9:\-\.%]+?/, :format => /html|json/
  get "/login", :to => 'sessions#new'
  get "/logout", :to => 'sessions#logout'
  get "/reservations", :to => 'reservations#current_user_reservations', :as => :current_user_reservations
  get "/availability/:room_id/:start", :to => 'reservations#availability', :start => /[TZtz0-9:\-\.%]+?/, :format => /html|json/, :as => :availability
  resources :reservations, :only => [:create, :update, :destroy]
  resources :users, :only => [:show]

  get "/admin", :to => 'admin#index'

  # admin panel access
  namespace :admin do
    resources :roles, :only => [:index, :new, :create, :update, :destroy]
    resources :rooms, :only => [:index, :new, :create, :edit, :update, :destroy]
    resources :settings, :only => [:index, :update]
  end
end