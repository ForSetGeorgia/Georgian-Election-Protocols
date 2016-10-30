BootstrapStarter::Application.routes.draw do

	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		match '/admin', :to => 'admin#index', :as => :admin, :via => :get
		devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}

		namespace :admin do
      resources :elections
			resources :users do
        collection do
          post :reset_training
        end
      end
  		match '/election_data', :to => 'election_data#index', :as => :election_data, :via => :get
  		match '/election_data/create_migration/:id', :to => 'election_data#create_migration', :as => :election_data_create_migration, :via => :get, :defaults => {:format => 'json'}
  		match '/election_data/notification_response', :to => 'election_data#notification', :as => :election_data_notification, :via => :get
  		match '/election_data/edit/:election_id/:district_id/:precinct_id', :to => 'election_data#edit', :as => :election_data_edit, :via => [:get,:put]
      match '/election_data/reset_bad_protocol_data', :to => 'election_data#reset_bad_protocol_data', :as => :election_data_reset_bad_protocol_data, :via => [:get,:put]

		end


    resources :crowd_data


    # json data
		match '/json/found_protocols', :to => 'json#found_protocols', :as => :json_found_protocols, :via => :get, :defaults => {:format => 'json'}
		match '/json/missing_protocols', :to => 'json#missing_protocols', :as => :json_missing_protocols, :via => :get, :defaults => {:format => 'json'}
    match '/json/all_protocols', :to => 'json#all_protocols', :as => :json_all_protocols, :via => :get, :defaults => {:format => 'json'}
		# match '/json/mark_found_protocols', :to => 'json#mark_found_protocols', :as => :json_mark_found_protocols, :via => [:get,:post], :defaults => {:format => 'json'}

		match '/protocol', :to => 'root#protocol', :as => :protocol, :via => [:get, :post]
		match '/training', :to => 'root#training', :as => :training, :via => [:get, :post]
		match '/download', :to => 'root#download', :as => :download, :via => :get
		match '/generate_spreadsheet/:id', :to => 'root#generate_spreadsheet', :as => :generate_spreadsheet, :via => :get, :default => {:format => 'csv'}
		match '/election_data_spreadsheet', :to => 'root#election_data_spreadsheet', :as => :election_data_spreadsheet, :via => :get, :default => {:format => 'csv'}
    match '/about', :to => 'root#about', :as => :about, :via => :get
    match '/view_protocol/:election_id', :to => 'root#view_protocol', :as => :view_protocol, :via => :get
    match '/categorize_supplemental_documents', :to => 'root#categorize_supplemental_documents', :as => :categorize_supplemental_documents, :via => [:get,:put]
    match '/moderate', :to => 'root#moderate', :as => :moderate, :via => :get
    match '/moderate_record', :to => 'root#moderate_record', :as => :moderate_record, :via => :post, :defaults => {:format => 'json'}



		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
