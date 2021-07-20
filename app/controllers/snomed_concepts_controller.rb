class SnomedConceptsController < ApplicationController

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

  def destroy
    authorize @snomed_concept

    respond_to do |format|
      format.html {  }
    end
  end
end
