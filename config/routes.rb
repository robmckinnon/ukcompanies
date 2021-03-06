def with_controller name, map
  map.with_options(:controller => name.to_s) { |sub_map| yield sub_map }
end

ActionController::Routing::Routes.draw do |map|

  number_requirements = {:requirements => { :number => Company::NUMBER_PATTERN } }

  with_controller :companies, map do |companies|
    companies.reconcile '/:country_code/reconcile', :action => 'reconcile'
    companies.suggest '/:country_code/suggest', :action => 'suggest'
    companies.flyout '/:country_code/flyout', :action => 'flyout'
    companies.view '/:country_code/:number/preview', :action => 'preview'

    companies.with_options(number_requirements) do |number|
      number.show_by_number '/:country_code/:number', :action=>'show_by_number'
      number.show_xml_by_number '/:country_code/:number.:format', :action=>'show_by_number'
      number.companies_house '/:country_code/:number/companies_house', :action => 'companies_house'
      number.show_by_number_and_name '/:country_code/:number/:name', :action=>'show_by_number_and_name'
      number.show_by_number_and_name_formatted '/:country_code/:number/:name.:format', :action=>'show_by_number_and_name'
    end
  end

  map.search 'search', :controller=>'companies', :action=>'search'

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  map.resources :companies, :except => [:show]

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home"
  map.rewired_state_presentation '/rewired_state_presentation', :controller => "home", :action => :rewired_state_presentation

  map.show_it_formatted '/:country_code/:number.:format', :conditions => { :method => :get }, :controller => 'companies', :action => 'show'
  map.show_it '/:country_code/:id', :conditions => { :method => :get }, :controller => 'companies', :action => 'show'
  # map.redirect_it '/:country_code/:id/companies_house', :conditions => { :method => :get }, :controller => 'companies', :action => 'companies_house'

  map.connect '*path', :controller => 'companies', :action => 'search'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
