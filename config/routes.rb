# frozen_string_literal: true

Rails.application.routes.draw do
  resources :fortain_pens, only: %i[index show destroy update]
end
