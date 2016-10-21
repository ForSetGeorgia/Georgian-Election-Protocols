class Admin::ElectionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end

  # GET /admin/elections
  # GET /admin/elections.json
  def index
    @elections = Election.sorted.with_translations(I18n.locale)

    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @elections }
    end
  end

  # GET /admin/elections/1
  # GET /admin/elections/1.json
  def show
    @election = Election.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json: @election }
    end
  end

  # GET /admin/elections/new
  # GET /admin/elections/new.json
  def new
    @election = Election.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
      @election.election_translations.build(:locale => locale)
    end


    respond_to do |format|
      format.html # new.html.erb
      # format.json { render json: @election }
    end
  end

  # GET /admin/elections/1/edit
  def edit
    @election = Election.find(params[:id])

    # turn the datetime picker js on
    # have to format dates this way so js datetime picker read them properly
    gon.election_at = @election.election_at.strftime('%m/%d/%Y %H:%M') if !@election.election_at.nil?
  end

  # POST /admin/elections
  # POST /admin/elections.json
  def create
    @election = Election.new(params[:election])

    respond_to do |format|
      if @election.save
        format.html { redirect_to admin_elections_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.election')) }
        # format.json { render json: @election, status: :created, location: @election }
      else
        # turn the datetime picker js on
        # have to format dates this way so js datetime picker read them properly
        gon.election_at = @election.election_at.strftime('%m/%d/%Y %H:%M') if !@election.election_at.nil?

        format.html { render action: "new" }
        # format.json { render json: @election.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/elections/1
  # PUT /admin/elections/1.json
  def update
    @election = Election.find(params[:id])

    # @election.assign_attributes(params[:election])

    respond_to do |format|
      if @election.update_attributes(params[:election])
        format.html { redirect_to admin_elections_path, notice: t('app.msgs.success_updated', :obj => t('activerecord.models.election')) }
        # format.json { head :no_content }
      else
        # turn the datetime picker js on
        # have to format dates this way so js datetime picker read them properly
        gon.election_at = @election.election_at.strftime('%m/%d/%Y %H:%M') if !@election.election_at.nil?

        format.html { render action: "edit" }
        # format.json { render json: @election.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/elections/1
  # DELETE /admin/elections/1.json
  def destroy
    @election = Election.find(params[:id])
    @election.destroy

    respond_to do |format|
      format.html { redirect_to admin_elections_url, notice: t('app.msgs.success_destroyed', :obj => t('activerecord.models.election')) }
      # format.json { head :no_content }
    end
  end
end
