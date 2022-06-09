# frozen_string_literal: true

Rails.application.routes.draw do
  # Defines the root path route ("/")
  root 'articles#index'

  resources :articles do
    resources :comments
  end

  resources :tags
  resources :taggings
end
