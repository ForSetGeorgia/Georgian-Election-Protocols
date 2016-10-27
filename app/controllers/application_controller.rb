class ApplicationController < ActionController::Base
	require 'will_paginate/array'
  protect_from_forgery

	before_filter :set_locale
	before_filter :is_browser_supported?
	before_filter :set_global_variables
	before_filter :initialize_gon

	unless Rails.application.config.consider_all_requests_local
		rescue_from Exception,
		            :with => :render_error
		rescue_from ActiveRecord::RecordNotFound,
		            :with => :render_not_found
		rescue_from ActionController::RoutingError,
		            :with => :render_not_found
		rescue_from ActionController::UnknownController,
		            :with => :render_not_found
		rescue_from ActionController::UnknownAction,
		            :with => :render_not_found

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to root_url, :alert => exception.message
    end
	end

	Browser = Struct.new(:browser, :version)
	SUPPORTED_BROWSERS = [
		Browser.new("Chrome", "15.0"),
		Browser.new("Safari", "4.0.2"),
		Browser.new("Firefox", "10.0.2"),
		Browser.new("Internet Explorer", "9.0"),
		Browser.new("Opera", "11.0")
	]

	def is_browser_supported?
		user_agent = UserAgent.parse(request.user_agent)
logger.debug "////////////////////////// BROWSER = #{user_agent}"
=begin
		if SUPPORTED_BROWSERS.any? { |browser| user_agent < browser }
			# browser not supported
logger.debug "////////////////////////// BROWSER NOT SUPPORTED"
			render "layouts/unsupported_browser", :layout => false
		end
=end
	end


	def set_locale
    if params[:locale] and I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
    end
	end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end

	def set_global_variables
    # get the events that are currently open for data entry
    @elections = Election.can_enter
    @election_ids = @elections.map{|x| x.id}

    # get a list of all elections
    @all_elections = Election.sorted

	  # the user stats are updated after a protocol is saved so do not need to call twice
	  if user_signed_in? && !(params[:contorller] == "root" && params[:action] == "protocol")
  		@user_stats = CrowdDatum.overall_stats_for_user(current_user.id, @election_ids)
		end

    if user_signed_in? && current_user.role?(User::ROLES[:categorize_supplemental_documents])
      # get user stats
      @supplemental_document_user_stats = SupplementalDocument.user_stats(current_user.id)
      # get document stats
      @document_stats = SupplementalDocument.document_stats
    end

    @bitly_url = 'http://bit.ly/Icounted'
	end

	def initialize_gon
		gon.set = true
		gon.highlight_first_form_field = true


	  if I18n.locale == :ka
	    gon.datatable_i18n_url = "/datatable_ka.txt"
	  else
	    gon.datatable_i18n_url = ""
	  end
	end

	def after_sign_in_path_for(resource)
		root_path
	end

  def valid_role?(role)
    redirect_to root_path, :notice => t('app.msgs.not_authorized') if !current_user || !current_user.role?(role)
  end


  #######################
	def render_not_found(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/404.html", :status => 404
	end

	def render_error(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/500.html", :status => 500
	end

end
