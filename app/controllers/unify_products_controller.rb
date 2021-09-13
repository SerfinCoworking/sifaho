class UnifyProductsController < ApplicationController
  before_action :set_unify_product, only: %i[show edit update destroy confirm_apply apply]

  # GET /unify_products
  # GET /unify_products.json
  def index
    @filterrific = initialize_filterrific(
      UnifyProduct,
      params[:filterrific],
      select_options: {
        sorted_by: UnifyProduct.options_for_sorted_by,
        for_statuses: UnifyProduct.options_for_status
      },
      persistence_id: false
    ) or return
    if request.format.xlsx? || request.format.pdf?
      @unify_products = @filterrific.find
    else
      @unify_products = @filterrific.find.paginate(page: params[:page], per_page: 20)
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /unify_products/1
  # GET /unify_products/1.json
  def show
  end

  # GET /unify_products/new
  def new
    @unify_product = UnifyProduct.new
  end

  # GET /unify_products/1/edit
  def edit
  end

  # POST /unify_products
  # POST /unify_products.json
  def create
    @unify_product = UnifyProduct.new(unify_product_params)

    respond_to do |format|
      if @unify_product.save
        format.html { redirect_to @unify_product, notice: 'Unificar producto se ha creado correctamente.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /unify_products/1
  # PATCH/PUT /unify_products/1.json
  def update
    respond_to do |format|
      if @unify_product.update(unify_product_params)
        format.html { redirect_to @unify_product, notice: 'Unificar producto se ha modificado correctamente.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /unify_products/1
  # DELETE /unify_products/1.json
  def destroy
    @unify_product.destroy
    respond_to do |format|
      format.html { redirect_to unify_products_url, notice: 'Unificar producto se ha eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  # GET /unify_products/1/confirm_apply
  def confirm_apply
    authorize @unify_product

    respond_to do |format|
      format.js
    end
  end

  # PATCH /unify_products/1/apply
  def apply
    authorize @unify_product

    respond_to do |format|
      if @unify_product.apply
        flash[:success] = 'Los productos se han unificado correctamente.'
      else
        flash[:alert] = 'Ha ocurrido un error al unificar los productos.'
      end
      format.html { redirect_to @unify_product }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_unify_product
    @unify_product = UnifyProduct.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def unify_product_params
    params.require(:unify_product).permit(:origin_product_id, :target_product_id, :observation)
  end
end
