IudealRadioCity::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.
  
  match '/biz'=> 'users#biz',:as => :biz
  match '/logout'=> 'users#destroy',:as => :logout
  match '/forgot'=> 'users#forgot',:as => :forgot
  match '/notifications' => 'home#notifications',:as => :notifications
  match '/products' => 'products#product_catalog',:as => :product_catalog
  match '/profile' => 'users#profile',:as => :profile

  match '/christmas_spirit' => 'home#christmas_spirit',:as => :christmas_spirit
  match '/payment/:id' => 'products#payments',:as => :payments
  match '/make_payment' => 'products#make_payment',:as => :make_payment
  match '/share_product' => 'products#share_product',:as => :share_product 
  match '/success/:id' => 'products#success',:as => :success
  match '/cancel' => 'products#cancel',:as => :cancel

  match '/:id' => 'products#capsule',:as => :capsule
  root :to => 'home#index'
  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
