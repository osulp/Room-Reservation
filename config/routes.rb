RoomReservation::Application.routes.draw do
  root :to => 'home#index'
  get "home/index"
  get "/login", :to => 'sessions#new'
end