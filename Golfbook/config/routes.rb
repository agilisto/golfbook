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
  
  map.tour_edit "/tours/edit/:id", :controller => "tours", :action => "edit", :only_path => true
  map.tour_show "/tours/show/:id", :controller => "tours", :action => "show", :only_path => true
  map.add_course_to_tour_by_location '/tours/:id/courses/searchbyloc', 
      :controller => 'tours', :action => "search_for_course_by_location", :only_path => true
  
  map.add_course_to_tour_by_name '/tours/:id/courses/searchbyname', 
      :controller => 'tours', :action => "search_for_course_by_name", :only_path => true

  map.invite_friends_to_tour "/tours/:id/users/new", :controller => "tours", :action => "addplayers", :only_path => true
  
  map.tour_add_course "/tours/:id/courses/add/:course_id", :controller => "tours", :action => "add_course", :only_path => true

  map.course_add_round '/courses/:id/round/new', 
    :controller => 'round', :action => 'new', 
    :only_path => true
      
  map.user_view_rounds '/profile/:id/rounds', 
    :controller => "profile", :action => "rounds", 
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
  
  map.user_view_wishlist '/profile/:user_id/wishlist/view', 
    :controller => 'wishlist', :action => 'index', 
    :only_path => true
  
  map.profile_view '/profile/:id/show',
    :controller => "profile", :action => "show", :only_path => true
      
  map.course_add_competition '/courses/:id/competition/new', 
    :controller => 'competitions', :action => 'new', 
    :only_path => true
  
  map.competition_show '/competitions/show/:id', 
    :controller => 'competitions', :action => 'show', 
    :only_path => true

  map.competition_new '/competitions/:id/new', 
    :controller => 'competitions', :action => 'new', 
    :only_path => true

  map.competition_edit '/competitions/:id/edit', 
    :controller => 'competitions', :action => 'edit', 
    :only_path => true
  
  map.competition_add_round '/competitions/:id/round/new', 
    :controller => 'competitions', :action => 'new_round', 
    :only_path => true

  map.invite_players 'competitions/:id/invite', 
    :controller => 'competitions', :action => 'invite_players', 
    :only_path => true

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end
