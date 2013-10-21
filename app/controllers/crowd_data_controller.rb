class CrowdDataController < ApplicationController
  # GET /crowd_data
  # GET /crowd_data.json
  def index
    @crowd_data = CrowdDatum.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @crowd_data }
    end
  end

  # GET /crowd_data/1
  # GET /crowd_data/1.json
  def show
    @crowd_datum = CrowdDatum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @crowd_datum }
    end
  end

  # GET /crowd_data/new
  # GET /crowd_data/new.json
  def new
    @crowd_datum = CrowdDatum.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @crowd_datum }
    end
  end

  # GET /crowd_data/1/edit
  def edit
    @crowd_datum = CrowdDatum.find(params[:id])
  end

  # POST /crowd_data
  # POST /crowd_data.json
  def create
    @crowd_datum = CrowdDatum.new(params[:crowd_datum])

    respond_to do |format|
      if @crowd_datum.save
        format.html { redirect_to @crowd_datum, notice: 'Crowd datum was successfully created.' }
        format.json { render json: @crowd_datum, status: :created, location: @crowd_datum }
      else
        format.html { render action: "new" }
        format.json { render json: @crowd_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /crowd_data/1
  # PUT /crowd_data/1.json
  def update
    @crowd_datum = CrowdDatum.find(params[:id])

    respond_to do |format|
      if @crowd_datum.update_attributes(params[:crowd_datum])
        format.html { redirect_to @crowd_datum, notice: 'Crowd datum was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @crowd_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /crowd_data/1
  # DELETE /crowd_data/1.json
  def destroy
    @crowd_datum = CrowdDatum.find(params[:id])
    @crowd_datum.destroy

    respond_to do |format|
      format.html { redirect_to crowd_data_url }
      format.json { head :ok }
    end
  end
end
