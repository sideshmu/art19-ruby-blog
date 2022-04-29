Rails.application.routes.draw do
  # Defines the root path route ("/")
  root "articles#index"
  
  get 'articles/index'
  
  resources :articles do
    resources :comments
  end
  
  # # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # get "/articles", to: "articles#index"
  # get "/articles/:id", to: "articles#show"
end
