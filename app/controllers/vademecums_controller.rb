class VademecumsController < ApplicationController
  before_action :set_vademecum, only: [:show, :edit, :update, :destroy]

  # GET /vademecums
  # GET /vademecums.json
  def index
    @vademecums = Vademecum.all
  end

  # GET /vademecums/1
  # GET /vademecums/1.json
  def show
  end

  # GET /vademecums/new
  def new
    @vademecum = Vademecum.new
  end

  # GET /vademecums/1/edit
  def edit
  end

  # POST /vademecums
  # POST /vademecums.json
  def create
    @vademecum = Vademecum.new(vademecum_params)

    respond_to do |format|
      if @vademecum.save
        format.html { redirect_to @vademecum, notice: 'Vademecum was successfully created.' }
        format.json { render :show, status: :created, location: @vademecum }
      else
        format.html { render :new }
        format.json { render json: @vademecum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vademecums/1
  # PATCH/PUT /vademecums/1.json
  def update
    respond_to do |format|
      if @vademecum.update(vademecum_params)
        format.html { redirect_to @vademecum, notice: 'Vademecum was successfully updated.' }
        format.json { render :show, status: :ok, location: @vademecum }
      else
        format.html { render :edit }
        format.json { render json: @vademecum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vademecums/1
  # DELETE /vademecums/1.json
  def destroy
    @vademecum.destroy
    respond_to do |format|
      format.html { redirect_to vademecums_url, notice: 'Vademecum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vademecum
      @vademecum = Vademecum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vademecum_params
      params.fetch(:vademecum, {})
    end
end
