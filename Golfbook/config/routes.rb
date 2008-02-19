ActionController::Routing::Routes.draw do |map|
 
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'home'

  map.course_add_round '/courses/:id/rounds/new', 
      :controller => 'round', :action => 'new', 
      :only_path => true
      
  map.user_view_rounds '/profile/:user_id/rounds/view', 
      :controller => 'round', :action => 'index', 
      :only_path => true
      
  map.course_have_played '/courses/:id/course_played/', 
      :controller => 'courses', :action => 'course_played', 
      :only_path => true
  
  map.course_add_wishlist '/courses/:id/wishlist/new', 
      :controller => 'wishlist', :action => 'new', 
      :only_path => true
  
  map.course_add_wishlist_target_date '/courses/:id/wishlist/target_date', 
      :controller => 'wishlist', :action => 'set_target_date', 
      :only_path => true
  
  map.course_create_competition 'competitions/:id/new', 
      :controller => 'competitions', :action => 'new', 
      :only_path => true

  map.user_view_wishlist '/profile/:user_id/wishlist/view', 
      :controller => 'wishlist', :action => 'index', 
      :only_path => true
      
  map.competition_select_course 'competitions/:id/select_course', 
      :controller => 'competitions', :action => 'select_course', 
      :only_path => true

  map.competition_course_selected 'competitions/:id/course_selected', 
      :controller => 'competitions', :action => 'course_selected', 
      :only_path => true

  map.competition_edit 'competitions/:id/edit', 
      :controller => 'competitions', :action => 'edit', 
      :only_path => true
  
  map.invite_players 'competitions/:id/invite', 
      :controller => 'competitions', :action => 'invite_players', 
      :only_path => true

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  

end
