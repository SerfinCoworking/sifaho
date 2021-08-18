class AreasController < ApplicationController
  before_action :set_area, only: %i[show edit update destroy fill_products_card]

  # GET /areas
  # GET /areas.json
  def index
    authorize Area
    @filterrific = initialize_filterrific(
      Area,
      params[:filterrific],
      select_options: {
        sorted_by: Area.options_for_sorted_by,
      },
      persistence_id: false
    ) or return
    @areas = @filterrific.find.paginate(page: params[:page], per_page: 15)
  end

  def tree_view
    authorize Area
    @areas = Area.filter(params.slice(:name))
      .order(name: :asc)
      .page(params[:page])

    @parent_areas = Area.main.order(name: :asc)
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /areas/1
  # GET /areas/1.json
  def show
    authorize @area
  end

  # GET /areas/new
  def new
    authorize Area
    @area = Area.new
    @areas = Area.all
  end

  # GET /areas/1/edit
  def edit
    authorize @area
  end

  # POST /areas
  # POST /areas.json
  def create
    @area = Area.new(area_params)
    authorize @area

    respond_to do |format|
      if @area.save
        format.html { redirect_to @area, notice: 'El rubro se ha creado correctamente.' }
        format.json { render :show, status: :created, location: @area }
      else
        format.html { render :new }
        format.json { render json: @area.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /areas/1
  # PATCH/PUT /areas/1.json
  def update
    authorize @area
    respond_to do |format|
      if @area.update(area_params)
        format.html { redirect_to @area, notice: 'El rubro se ha modificado correctamente.' }
        format.json { render :show, status: :ok, location: @area }
      else
        format.html { render :edit }
        format.json { render json: @area.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /areas/1
  # DELETE /areas/1.json
  def destroy
    authorize @area
    @area.destroy
    respond_to do |format|
      format.html { redirect_to areas_url, notice: 'El rubro se ha enviado a la papelera correctamente.' }
      format.json { head :no_content }
    end
  end

  def fill_products_card
    @products = @area.all_nested_products

    respond_to do |format|
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_area
    @area = Area.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def area_params
    params.require(:area).permit(:name, :parent_id)
  end
end
