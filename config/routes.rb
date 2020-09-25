# frozen_string_literal: true

Rails.application.routes.draw do
  resources :fortain_pens, only: %i[index] do
    collection do
      post 'import'
    end
  end
end
