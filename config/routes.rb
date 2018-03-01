Rails.application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  root :to => 'reserves#index'
  
  match 'reserves/:id/clone' => 'reserves#clone', :as => :clone_reserve, :via => :get
  match 'reserves/add_item(.:format)' => 'reserves#add_item', :as => :add_reserves_item, :via => :get 
  match 'all_courses' => 'reserves#all_courses', :as => :all_courses, :via => :get 
  match 'all_courses_response' => 'reserves#all_courses_response', :as => :all_courses_response, :via => :get 
  
  resources :reserves
  
  resource :feedback_form, path: 'feedback', only: [:new, :create]
  get 'feedback' => 'feedback_forms#new'
end
