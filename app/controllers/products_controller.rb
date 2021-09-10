class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy delete]

  # GET /products
  # GET /products.json
  def index
    authorize Product

    @filterrific = initialize_filterrific(
      Product,
      params[:filterrific],
      select_options: {
        sorted_by: Product.options_for_sorted_by,
        for_statuses: Product.options_for_status
      },
      persistence_id: false
    ) or return
    @areas = Area.all
    if request.format.xlsx? || request.format.pdf?
      @products = @filterrific.find
    else
      @products = @filterrific.find.paginate(page: params[:page], per_page: 20)
    end
    respond_to do |format|
      format.html
      format.js
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"ReporteListadoProductos_#{DateTime.now.strftime('%d-%m-%Y')}.xlsx\"" }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    authorize @product

    @stock_quantity = current_user.sector.stock_to(@product.id)
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /products/new
  def new
    authorize Product
    @product = Product.new
    @unities = Unity.all
    @areas = Area.all
  end

  # GET /products/1/edit
  def edit
    authorize @product
    @unities = Unity.all
    @areas = Area.all
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)
    @new_product_lot = Product.new
    authorize @product

    respond_to do |format|
      if @product.save
        flash.now[:success] = "El insumo "+@product.name+" se ha creado correctamente."
        format.html { redirect_to @product }
      else
        @unities = Unity.all
        @areas = Area.all
        flash.now[:error] = "El insumo no se ha podido crear."
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    authorize @product
    respond_to do |format|
      if @product.update(product_params)
        flash.now[:success] = "El insumo "+@product.name+" se ha modificado correctamente."
        format.html { redirect_to @product}
      else
        @unities = Unity.all
        @areas = Area.all
        flash.now[:error] = "El insumo "+@product.name+" no se ha podido modificar."
        format.html { render :edit }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    authorize @product
    @product_name = @product.name
    @product.destroy
    respond_to do |format|
      flash.now[:success] = "El suministro "+@product_name+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /product/1/delete
  def delete
    authorize @product
    respond_to do |format|
      format.js
    end
  end

  # GET /product/1/restore_confirm
  def restore_confirm
    respond_to do |format|
      format.js
    end
  end

  # GET /product/1/restore
  def restore
    authorize @product
    Product.restore(@product.id, :recursive => true)

    respond_to do |format|
      flash.now[:success] = "El insumo código "+@product.id.to_s+" se ha restaurado correctamente."
      format.js
    end
  end

  def search_by_name
    @products = Product.active.order(:name).search_name(params[:term]).limit(8)
    render json: @products.map { |product| {
        label: product.name,
        id: product.id,
        code: product.code,
        unity: product.unity.name,
        stock: current_user.sector.stock_to(product.id)
      }
    }
  end

  def search_by_code
    @products = Product.active.order(:id).with_code(params[:term]).limit(8)
    render json: @products.map { |product| {
      label: product.code,
      id: product.id,
      name: product.name,
      unity: product.unity.name,
      stock: current_user.sector.stock_to(product.id)
    } 
  }
  end

  def search_by_name_to_order
    @area_ids = params[:area_ids].split("_")
    @products = Product.active.order(:name).search_name(params[:term]).with_area_ids(@area_ids).limit(8)
    render json: @products.map { |product| {
        label: product.name,
        id: product.id,
        code: product.code,
        unity: product.unity.name,
        stock: current_user.sector.stock_to(product.id)
      }
    }
  end

  def search_by_code_to_order
    @area_ids = params[:area_ids].split("_")
    @products = Product.order(:id).with_code(params[:term]).with_area_ids(@area_ids).limit(8)
    render json: @products.map{ |product| { 
      label: product.code, 
      id: product.id,
      name: product.name,
      unity: product.unity.name,
      stock: current_user.sector.stock_to(product.id)
    } 
  }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.require(:product).permit(:code, :name, :unity_id, :area_id, :description, :observation, :snomed_concept_id)
  end
end
