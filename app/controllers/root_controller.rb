class RootController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :download, :generate_spreadsheet, :about]
  require 'utf8_converter'

  PROTOCOL_NUMBERS = (1..5).to_a

  def index
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
     #CrowdDatum.numerical_values_provided(params[:crowd_datum])
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
        params['protocol'][k] = v.strip
        if params['protocol'][k] == '0'
          params['protocol'][k] = ''
        end
      }

      @next_protocol = params['protocol_number']
      filedata = JSON.parse(File.read('public/training/' + @next_protocol + '.json'))
      if filedata == params['protocol']
        trained = (trained + [@next_protocol.to_i]).uniq.sort
        user.trained = trained.join(',')
        user.save
        @user_trained_num = user.trained.length
  			flash[:notice] = I18n.t('root.training.success')
      else
        @errors = {}
        filedata.each_pair do |key, value|
          pval = params['protocol'][key]
          if pval.length > 0 && pval.gsub(/[a-zA-Z]/, '') != pval
            @errors[key] = I18n.t('root.training.errors.number')
          elsif value != pval
            @errors[key] = I18n.t('root.training.errors.mismatch')
          end
        end
  			flash[:alert] = I18n.t('root.training.errors.incorrect')
      end
    end

    # if no errors, load the next protocol
    if @errors.blank?
      params['protocol'] = nil # make sure form fields are not pre-populated with the last form
      if user.trained.blank?
        @next_protocol = PROTOCOL_NUMBERS.sample
      else
        left = PROTOCOL_NUMBERS - trained
        if left.present?
          @next_protocol = left.sample
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
    @all_elections = Election.with_data.sorted
    @overall_stats = DistrictPrecinct.overall_stats(@all_elections.map{|x| x.id})

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def generate_spreadsheet

    election = Election.with_data.by_analysis_table_name(params[:id])

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



  protected

	# remove bad characters from file name
	def clean_filename(filename)
		Utf8Converter.convert_ka_to_en(filename.gsub(' ', '_').gsub(/[\\ \/ \: \* \? \" \< \> \| \, \. ]/,''))
	end

end
