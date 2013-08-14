RoomReservation::Application.routes.draw do
  root :to => 'home#index'
  get "home/index"
  get "/login", :to => 'sessions#new'
  get "/logout", :to => 'sessions#logout'
end