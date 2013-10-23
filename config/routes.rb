BootstrapStarter::Application.routes.draw do

	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		match '/admin', :to => 'admin#index', :as => :admin, :via => :get
		devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}

		namespace :admin do
			resources :users
		end


    resources :crowd_data


    # json data
		match '/json/missing_protocols', :to => 'json#missing_protocols', :as => :json_missing_protocols, :via => :get, :defaults => {:format => 'json'}
		match '/json/mark_found_protocols', :to => 'json#mark_found_protocols', :as => :json_mark_found_protocols, :via => [:get,:post], :defaults => {:format => 'json'}


		match '/training', :to => 'root#training', :as => :training, :via => [:get, :post]


		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
