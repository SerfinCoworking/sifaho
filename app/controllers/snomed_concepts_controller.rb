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

  def show
    
  end

  def edit
    
  end

  def create
    
  end

  def update
    
  end
end
