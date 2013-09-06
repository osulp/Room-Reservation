RoomReservation::Application.routes.draw do
  root :to => 'home#index'
  get "home/index"
  get "/home/day/:date", :to => "home#day"
  get "/login", :to => 'sessions#new'
  get "/logout", :to => 'sessions#logout'
  get "/reservations", :to => 'reservation#current_user_reservations', :as => :current_user_reservations
  get "/availability/:room_id/:start", :to => 'reservation#availability', :as => :availability
  resources :reservations, :only => [:create, :update, :destroy]
end