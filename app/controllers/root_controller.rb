class RootController < ApplicationController
  before_filter :authenticate_user!, :except => :index
  PROTOCOL_NUMBERS = (1..5).to_a

  def index
    @overall_stats = DistrictPrecinct.overall_stats
    @overall_stats_by_district = DistrictPrecinct.overall_stats_by_district
    @overall_user_stats = CrowdDatum.overall_user_stats

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def protocol

    # if the user has not completed training send them there
    trained = current_user.trained.present? ? current_user.trained.split(',') : []
    if trained.length < PROTOCOL_NUMBERS.length
      redirect_to training_path, :notice => I18n.t('root.protocol.no_training')
      return
    end

    valid = true
    if request.post?
      @crowd_datum = CrowdDatum.new(params[:crowd_datum])
      valid = @crowd_datum.save
  		@user_stats = CrowdDatum.overall_stats_by_user(current_user.id)
    end

    # get the next record if there were no errors
    @crowd_datum = CrowdDatum.next_available_record(current_user.id) if valid
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def training
    user = User.find(current_user.id)
    trained = user.trained.present? ? user.trained.split(',') : []
    trained = trained.map{|x| x.to_i}

    if params['protocol'].present?
      @next_protocol = params['protocol_number']
      filedata = JSON.parse(File.read('public/training/' + @next_protocol + '.json'))
      if filedata == params['protocol']
        trained = (trained + [@next_protocol.to_i]).uniq.sort
        user.trained = trained.join(',')
        user.save
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

end
