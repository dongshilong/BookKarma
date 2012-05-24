BookKarma::Application.routes.draw do
  resources :books

#resources  resources :users
  resources :sessions, :only => [:new, :create, :destroy]


  match "/login" => "sessions#new", as: "login"
  match "/logout" => "sessions#destroy", as: "logout"

  root :to => "sessions#new"

end
