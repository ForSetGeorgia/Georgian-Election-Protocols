class RootController < ApplicationController
  before_filter :authenticate_user!, :except => :index

  def index
    @overall_stats = DistrictPrecinct.overall_stats
    @overall_stats_by_district = DistrictPrecinct.overall_stats_by_district
    @overall_user_stats = CrowdDatum.overall_user_stats

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def protocol

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
    protocols = (1..5).to_a

    user = User.find(current_user.id)
    trained = user.trained.present? ? user.trained.split(',') : []
    trained = trained.map{|x| x.to_i}

    if params['protocol'].present?
      @next_protocol = params['protocol_number']
      filedata = JSON.parse(File.read('public/training/' + @next_protocol + '.json'))
      if filedata == params['protocol']
        trained << @next_protocol
        user.trained = trained.join(',')
        user.save
  			flash[:notice] = I18n.t('root.training.success')
      else
        @errors = []
        filedata.each_pair do |key, value|
          if value != params['protocol'][key]
            @errors.push(key)
          end
        end
  			flash[:alert] = I18n.t('root.training.data_mismatch')
      end
    end

    # if no errors, load the next protocol
    if @errors.blank?
      params['protocol'] = nil # make sure form fields are not pre-populated with the last form
      if user.trained.blank?
        @next_protocol = protocols.sample
      else
        left = protocols.reject{|x| trained.include?(x)}
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
