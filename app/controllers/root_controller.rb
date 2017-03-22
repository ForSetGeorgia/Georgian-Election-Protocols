class RootController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :download, :generate_spreadsheet, :about, :view_protocol]
  before_filter only: :categorize_supplemental_documents do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:categorize_supplemental_documents])
  end
  before_filter only: [:moderate, :moderate_record] do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:moderator])
  end

  require 'utf8_converter'

  PROTOCOL_NUMBERS = (1..5).to_a

  def index

    if @all_elections.present?
      params[:election] = @all_elections.first.analysis_table_name if params[:election].nil?
      @current_election = @all_elections.select{|x| x.analysis_table_name == params[:election]}.first

      # get the events that are currently open for data entry
      @overall_stats = DistrictPrecinct.overall_stats(@current_election.id)
      @overall_stats_by_district = DistrictPrecinct.overall_stats_by_district(@current_election.id)
      @overall_user_stats = CrowdDatum.overall_user_stats(@current_election.id)
      @annulled = DistrictPrecinct.by_election(@current_election.id).has_been_annulled
      @district_summaries = @current_election.district_summary
      @needs_clarifications = DistrictPrecinct.by_election(@current_election.id).needs_clarification

      # make sure all districts/precincts appear whether or not they have been entered yet
      # so use raw as baseline and add anything missing from dp
      @supplemental_documents = @current_election.raw_with_supplemental_documents
      supplemental_documents_dp = DistrictPrecinct.by_election(@current_election.id).with_supplemental_documents
      supplemental_documents_dp.each do |dp|
        if @supplemental_documents.index{|x| x['district_id'] == dp.district_id && x['precinct_id'] == dp.precinct_id}.nil?
          @supplemental_documents << dp
        end
      end

    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def index_old
    # get the events that are currently open for data entry
    @overall_stats = DistrictPrecinct.overall_stats(@election_ids)
    @overall_stats_by_district = DistrictPrecinct.overall_stats_by_district(@election_ids)
    @overall_user_stats = CrowdDatum.overall_user_stats(@election_ids)

    # if there are no current elections, see if there are elections coming up
    if @elections.nil? || @elections.empty?
      @elections_coming_up = Election.coming_up.sorted
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def about
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def view_protocol
    @election = Election.find_by_analysis_table_name(params[:election_id])
    if @election.present?
      dp = DistrictPrecinct.by_ids(@election.id, params[:district_id], params[:precinct_id]).first

      if dp.present? && dp.has_protocol?
        @crowd_datum = CrowdDatum.new(election_id: dp.election_id, district_id: dp.district_id, precinct_id: dp.precinct_id)
      end

      respond_to do |format|
        format.html # index.html.erb
      end

    else
      # election not found, send them back to home page
      redirect_to root_path, alert: I18n.t('app.msgs.could_not_find_election')
      return
    end
  end

  def protocol
    logger.info "%%%%%%%%%%%% protocol start"
    @protocol_manipulator = true
    # if the user has not completed training send them there
    if !current_user.completed_training?
      redirect_to training_path, :notice => I18n.t('root.protocol.no_training')
      return
    end

    valid = true
    if request.post?
      logger.info "%%%%%%%%%%%% - request is post"

      if params[:crowd_datum].has_key?(:moderation_reason)
        # this is a cant enter submission

        # make sure something was selected
        if params[:crowd_datum][:moderation_reason] != ['']
          DistrictPrecinct.add_moderation(params[:crowd_datum][:election_id], params[:crowd_datum][:district_id],
                        params[:crowd_datum][:precinct_id], current_user.id, params[:crowd_datum][:moderation_reason])
        end
      else
        # this is a normal data entry submission
        params[:crowd_datum] = CrowdDatum.extract_numbers(params[:crowd_datum])

        # in case users are refreshing page, look to see if the record already exists
        # if so, ignore it, else create it
        @crowd_datum = CrowdDatum.by_ids(params[:crowd_datum][:election_id], params[:crowd_datum][:district_id], params[:crowd_datum][:precinct_id])
                        .by_user(params[:crowd_datum][:user_id]).first
        if @crowd_datum.nil?
          @crowd_datum = CrowdDatum.new(params[:crowd_datum])
          valid = @crowd_datum.save
        else
          logger.info "!!!!!! record already exists, so ignoring submission"
          valid = true
        end
    		@user_stats = CrowdDatum.overall_stats_for_user(current_user.id, @election_ids)
      end
    end

    # get the next record if there were no errors
   # @crowd_datum = CrowdDatum.new(election_id: 3, district_id: '11', precinct_id: "06.15", user_id: current_user.id)
    logger.info "%%%%%%%%%%%% - calling next available"
    @crowd_datum = CrowdDatum.next_available_record(current_user.id) if valid
    if @crowd_datum.present?
      logger.info "%%%%%%%%%%%% - record found, getting matching election and parties"
      # get the election
      @election = Election.find(@crowd_datum.election_id)
      # get the parties for the election
      @party_numbers = Party.by_election_district(@crowd_datum.election_id, @crowd_datum.district_id).party_numbers
    else
      redirect_to root_path, :notice => I18n.t('app.msgs.no_protocols')
      return
    end
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def training
    @protocol_manipulator = true
    user = User.find(current_user.id)
    trained = user.trained
    @user_trained_num = trained.length

    if params['protocol'].present?
      # if the user entered a 0, reset to '' so matching works
      # trim the values so there are no leading spaces
      params['protocol'].each{|k,v|
        if k != 'moderation_reason'
          params['protocol'][k] = v.strip
          if params['protocol'][k] == '0'
            params['protocol'][k] = ''
          end
        end
      }

      @next_protocol = params['protocol_number']
      @protocol_data = JSON.parse(File.read("public/training/#{@next_protocol}.json"))
      errors = validate_training_values(@protocol_data, params['protocol'])
      if errors.keys.length == 0
        trained = (trained + [@next_protocol.to_i]).uniq.sort
        user.trained = trained.join(',')
        user.save
        @user_trained_num = user.trained.length
  			flash[:notice] = I18n.t('root.training.success')
      else
        @errors = errors
  			flash[:alert] = I18n.t('root.training.errors.incorrect')
      end
    end

    # if no errors, load the next protocol
    if @errors.blank?
      params['protocol'] = nil # make sure form fields are not pre-populated with the last form
      if user.trained.blank?
        @next_protocol = 5#PROTOCOL_NUMBERS.sample
        @protocol_data = JSON.parse(File.read("public/training/#{@next_protocol}.json"))
      else
        left = PROTOCOL_NUMBERS - trained
        if left.present?
          @next_protocol = left.sample
          @protocol_data = JSON.parse(File.read("public/training/#{@next_protocol}.json"))
        else
          redirect_to protocol_path, :notice => I18n.t('root.training.completed')
          return
        end
      end
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def download
    @overall_stats = DistrictPrecinct.overall_stats(@all_elections.map{|x| x.id})

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def generate_spreadsheet

    election = Election.by_analysis_table_name(params[:id])

    if election.nil?
      redirect_to download_path, alert: I18n.t('app.msgs.could_not_find_election')
      return
    end

		# create file name using event name and map title that were passed in
    filename = params[:id]
		filename << "-#{l Time.now, :format => :file}"
    csv_data = election.download_raw_data

    if csv_data.nil?
      redirect_to download_path, alert: I18n.t('app.msgs.could_not_find_election')
      return
    end

		respond_to do |format|
		  format.csv {
logger.debug ">>>>>>>>>>>>>>>> format = csv"
        send_data csv_data,
		      :type => 'text/csv; header=present',
		      :disposition => "attachment; filename=#{clean_filename(filename)}.csv"
			}

		  format.xls{
logger.debug ">>>>>>>>>>>>>>>> format = xls"
				send_data csv_data,
		    :disposition => "attachment; filename=#{clean_filename(filename)}.xls"
			}
		end

  end


  def election_data_spreadsheet

		# create file name using event name and map title that were passed in
    filename = I18n.t('app.common.file_name')
		filename << "-#{l Time.now, :format => :file}"

		respond_to do |format|
		  format.csv {
logger.debug ">>>>>>>>>>>>>>>> format = csv"
        send_data President2013.download_election_map_data,
		      :type => 'text/csv; header=present',
		      :disposition => "attachment; filename=#{clean_filename(filename)}.csv"
			}
		end
  end


  # indicate the type of the document
  def categorize_supplemental_documents

    if request.put?
      supplemental_document = SupplementalDocument.find(params[:supplemental_document][:id])
      params[:supplemental_document].delete(:id) # do this so not get mass assignment error
      supplemental_document.update_attributes(params[:supplemental_document]) if supplemental_document.present?
    end

    # get the next doc
    @supplemental_document = SupplementalDocument.next_to_categorize
  end


  def moderate
    @needs_moderation = DistrictPrecinct.with_elections.sort_issue_reported_at

    if params[:status].present? && params[:status] == 'completed'
      @needs_moderation = @needs_moderation.was_moderated
    else
      params[:status] = 'pending'
      @needs_moderation = @needs_moderation.needs_moderation
    end

    gon.moderate_record_url = moderate_record_path
    gon.moderate_notes_url = moderate_notes_path

  end

  def moderate_record
    if params[:id].present? && params[:action_to_take].present? && params[:user_id].present?
      response = nil
      errors = nil
      case params[:action_to_take].downcase
        when 'annulled'
          success = DistrictPrecinct.mark_as_annulled(params[:id], params[:user_id])
          if success
            response = {status: I18n.t('root.moderate.status.annulled'), time: I18n.l(Time.now, format: :file)}
          else
            errors = {status: I18n.t('root.moderate.moderate.failed')}
          end
        when 'request_image'
          success = DistrictPrecinct.request_new_image(params[:id], params[:user_id])
          if success
            response = {status: I18n.t('root.moderate.status.request_image'), time: I18n.l(Time.now, format: :file)}
          else
            errors = {status: I18n.t('root.moderate.moderate.failed')}
          end
        when 'contact_cec'
          success = DistrictPrecinct.mark_as_contact_cec(params[:id], params[:user_id])
          if success
            response = {status: I18n.t('root.moderate.status.contact_cec'), time: I18n.l(Time.now, format: :file)}
          else
            errors = {status: I18n.t('root.moderate.moderate.failed')}
          end
        when 'supplementary_document_added'
          success = DistrictPrecinct.mark_as_supplementary_document_added(params[:id], params[:user_id])
          if success
            response = {status: I18n.t('root.moderate.status.supplementary_document_added'), time: I18n.l(Time.now, format: :file)}
          else
            errors = {status: I18n.t('root.moderate.moderate.failed')}
          end
        when 'no_problem'
          success = DistrictPrecinct.cancel_moderation(params[:id], params[:user_id])
          if success
            response = {status: I18n.t('root.moderate.status.no_problem'), time: I18n.l(Time.now, format: :file)}
          else
            errors = {status: I18n.t('root.moderate.moderate.failed')}
          end
      end

      respond_to do |format|
        format.json { render json: {response: response, errors: errors}}
      end

    else
      respond_to do |format|
        format.json { render json: {errors: {status: I18n.t('root.moderate.moderate.failed')}}}
      end
    end

  end


  def moderate_notes
    if params[:id].present? && params[:notes].present? && params[:user_id].present?
      response = nil
      errors = nil
      success = DistrictPrecinct.add_moderation_notes(params[:id], params[:notes], params[:user_id])
      if success
        response = {time: I18n.l(Time.now, format: :file)}
      else
        errors = {status: I18n.t('root.moderate.moderate.failed')}
      end
      respond_to do |format|
        format.json { render json: {response: response, errors: errors}}
      end

    else
      respond_to do |format|
        format.json { render json: {errors: {status: I18n.t('root.moderate.moderate.failed')}}}
      end
    end
  end

protected

	# remove bad characters from file name
	def clean_filename(filename)
		Utf8Converter.convert_ka_to_en(filename.gsub(' ', '_').gsub(/[\\ \/ \: \* \? \" \< \> \| \, \. ]/,''))
	end

  def validate_training_values(actual, submitted)
    errors = Hash.new

    # check if cant_enter is supposed to exist
    if actual['cant_enter'].present?
      moderation_reason = nil
      if submitted['moderation_reason'].present?
        submitted['moderation_reason'].delete('')
        moderation_reason = submitted['moderation_reason'].first
      end
      if actual['cant_enter'] != moderation_reason
        errors['cant_enter'] = I18n.t('root.training.errors.cant_enter')
      end
    end

    if !errors.keys.present? && !actual['cant_enter'].present?

      # top box
      actual['top_box'].each do |item|
        if item['value'] != submitted[item['key']]
          errors[item['key']] = I18n.t('root.training.errors.mismatch')
        end
      end

      # parties
      actual['parties'].each do |item|
        if item['value'] != submitted[item['key']]
          errors[item['key']] = I18n.t('root.training.errors.mismatch')
        end
      end

      # bottom box
      actual['bottom_box'].each do |item|
        if item['value'] != submitted[item['key']]
          errors[item['key']] = I18n.t('root.training.errors.mismatch')
        end
      end
    end

    return errors
  end

end
