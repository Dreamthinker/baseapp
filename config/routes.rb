# See how all your routes lay out with "rake routes"
ActionController::Routing::Routes.draw do |map|
  
  map.resources :users
  map.resource :session
  
  # Account shortcuts
  map.signup   '/signup',   :controller => 'users',    :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users',    :action => 'activate'
  map.login    '/login',    :controller => 'sessions', :action => 'new'
  map.logout   '/logout',   :controller => 'sessions', :action => 'destroy', :conditions => {:method => :delete}
  
  # Profiles
  map.resources :profiles
  
  # Administration
  map.namespace(:admin) do |admin|
    admin.root :controller => 'dashboard', :action => 'index'
    admin.resources :users, :member => { :suspend   => :put,
                                         :unsuspend => :put,
                                         :activate  => :put, 
                                         :purge     => :delete }
  end
  
  # Dashboard as the default location
  map.root :controller => 'dashboard', :action => 'index'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
