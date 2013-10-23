class RootController < ApplicationController

  def index
    @overall_stats = DistrictPrecinct.overall_stats
    @overall_stats_by_district = DistrictPrecinct.overall_stats_by_district
    @overall_user_stats = CrowdDatum.overall_user_stats
  end


  def training
    protocols = (1..5).to_a

    user = User.find(1)

    if params['protocol'].nil?
      if user.trained.blank?
        @next_protocol = protocols.sample
      else
        trained = user.trained.split(',')
        left = protocols - trained
        if left.length
          @next_protocol = left.sample
        else
          redirect_to root_path, :notice => I18n.t('root.training.completed')
        end
      end
    elsif
      @next_protocol = params['protocol_number']
      filedata = JSON.parse(File.read('public/training/' + @next_protocol + '.json'))
      if filedata == params['protocol']
        user.update(:trained => (user.trained.split(',') + [@next_protocol]).join(','))
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

    render :template => 'root/training'
  end

end
