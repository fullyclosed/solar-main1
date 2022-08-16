Rails.application.routes.draw do
  devise_for :users
  # resources :invoices    
  get 'download' => 'invoices#download'
  root "welcome#index"
end
