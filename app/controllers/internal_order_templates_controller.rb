class InternalOrderTemplatesController < ApplicationController
  before_action :set_internal_order_template, only: [:show, :edit, :update, :destroy]

  # GET /internal_order_templates
  # GET /internal_order_templates.json
  def index
    authorize InternalOrderTemplate
    @internal_order_templates = InternalOrderTemplate.all
  end

  # GET /internal_order_templates/1
  # GET /internal_order_templates/1.json
  def show
    authorize @internal_order_template
  end

  # GET /internal_order_templates/new
  def new
    authorize InternalOrderTemplate
    @internal_order_template = InternalOrderTemplate.new
  end

  # GET /internal_order_templates/1/edit
  def edit
    authorize @internal_order_template
  end

  # POST /internal_order_templates
  # POST /internal_order_templates.json
  def create
    authorize InternalOrderTemplate
    @internal_order_template = InternalOrderTemplate.new(internal_order_template_params)

    respond_to do |format|
      if @internal_order_template.save
        format.html { redirect_to @internal_order_template, notice: 'Internal order template was successfully created.' }
        format.json { render :show, status: :created, location: @internal_order_template }
      else
        format.html { render :new }
        format.json { render json: @internal_order_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /internal_order_templates/1
  # PATCH/PUT /internal_order_templates/1.json
  def update
    authorize @internal_order_template
    respond_to do |format|
      if @internal_order_template.update(internal_order_template_params)
        format.html { redirect_to @internal_order_template, notice: 'Internal order template was successfully updated.' }
        format.json { render :show, status: :ok, location: @internal_order_template }
      else
        format.html { render :edit }
        format.json { render json: @internal_order_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /internal_order_templates/1
  # DELETE /internal_order_templates/1.json
  def destroy
    authorize @internal_order_template
    @internal_order_template.destroy
    respond_to do |format|
      format.html { redirect_to internal_order_templates_url, notice: 'Internal order template was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /internal_order_templates/1/delete
  def delete
    authorize @internal_order_template
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_internal_order_template
      @internal_order_template = InternalOrderTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def internal_order_template_params
      params.require(:internal_order_template).permit(:name, :owner_sector_id, :detination_sector_id, :order_type)
    end
end
