class SnomedConceptsController < ApplicationController
  before_action :set_snomed_concept, only: %i[show edit update delete destroy]

  def index
    authorize SnomedConcept
    @filterrific = initialize_filterrific(
      SnomedConcept,
      params[:filterrific],
      select_options: {
        sorted_by: SnomedConcept.options_for_sorted_by
      },
      persistence_id: false
    ) or return
    @snomed_concepts = @filterrific.find.paginate(page: params[:page], per_page: 20)
  end

  def new
    authorize SnomedConcept
    @snomed_concept = SnomedConcept.new
  end

  def show
    authorize @snomed_concept
  end

  def edit
    authorize @snomed_concept
  end

  def create
    @snomed_concept = SnomedConcept.new(snomed_concept_params)
    authorize @snomed_concept

    respond_to do |format|
      if @snomed_concept.save
        flash.now[:success] = 'El concepto se ha agregado correctamente'
        format.html { redirect_to @snomed_concept }
      else
        flash.now[:error] = 'No se ha podido agregar el concepto'
        format.html { render :new }
      end
    end
  end

  def update
    authorize @snomed_concept

    respond_to do |format|
      if @snomed_concept.update(snomed_concept_params)
        flash.now[:success] = 'El concepto se ha editado correctamente.'
        format.html { redirect_to @snomed_concept }
      else
        flash.now[:error] = 'El concepto no se ha podido editar correctamente.'
        format.html { render :edit }
      end
    end
  end

  def find_new
    # @results = AndesServices::FindSnomedConcept.new(params).call
    @searched_term = params[:term]
    @semantic_tag = params[:semantic_tag].join(', ') if params[:semantic_tag].present?
    @result = JSON.parse(RestClient::Request.execute(method: :get, url: "#{ENV['ANDES_SNOMED_URL']}/",
                                                     timeout: 120, headers: {
                                                       params: { 'search': params[:term],
                                                                 'semanticTag': @semantic_tag }
                                                     }))
    respond_to do |format|
      format.js
    end
  end

  def destroy
    authorize @snomed_concept
    respond_to do |format|
      begin
        @snomed_concept.destroy
        flash.now[:success] = 'El concepto se ha eliminado correctamente.'
      rescue ActiveRecord::DeleteRestrictionError
        flash.now[:error] = I18n.t('errors.messages.restrict_dependent_destroy',
                                   attribute: SnomedConcept.human_attribute_name('products_count'))
        # flash.now[:error] = @snomed_concept.errors.messages[:restrict_dependent_destroy]
      ensure
        format.js
      end
    end
  end

  def delete
    authorize @snomed_concept
    respond_to do |format|
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_snomed_concept
    @snomed_concept = SnomedConcept.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def snomed_concept_params
    params.require(:snomed_concept).permit(:concept_id, :term, :fsn, :semantic_tag)
  end
end
