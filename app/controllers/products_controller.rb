class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :delete]

   # GET /products
  # GET /products.json
  def index
    authorize Product
    @filterrific = initialize_filterrific(
      Product,
      params[:filterrific],
      select_options: {
        sorted_by: Product.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'codigo_asc'},
      available_filters: [
        :sorted_by,
        :search_product,
        :search_code,
        :with_area_id,
      ],
    ) or return
    @products = @filterrific.find.page(params[:page]).per_page(15)
    @areas = Area.all
  end

  # GET /products
  # GET /products.json
  def trash_index
    authorize Product
    @filterrific = initialize_filterrific(
      Product.only_deleted,
      params[:filterrific],
      select_options: {
        sorted_by: Product.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'codigo_asc'},
      available_filters: [
        :sorted_by,
        :search_product,
        :with_code,
        :with_area_id,
      ],
    ) or return
    @products = @filterrific.find.page(params[:page]).per_page(15)
    @areas = Area.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
    authorize @product
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
        format.js
      else
        @unities = Unity.all
        @areas = Area.all
        flash.now[:error] = "El insumo "+@product.name+" no se ha podido modificar."
        format.js
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
    @products = Product.order(:name).search_text(params[:term]).limit(15)
    render json: @products.map{ |sup| { label: sup.name, id: sup.id, expiry: sup.needs_expiration,
      unity: sup.unity, product_area: sup.product_area.name } }
  end

  def search_by_id
    @products = Product.order(:id).with_code(params[:term]).limit(8)
    render json: @products.map{ |sup| { label: sup.id.to_s+" "+sup.name, value: sup.id,
      name: sup.name , expiry: sup.needs_expiration, unity: sup.unity, product_area: sup.product_area.name } }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.with_deleted.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:code, :name, :unity_id, :area_id, :description, :observation)
    end
end
