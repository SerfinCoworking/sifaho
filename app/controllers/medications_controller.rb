class MedicationsController < ApplicationController
#show all medications
def index

end

def show
end

#create new medication
def new
  @medication = Medication.new
end

#search a medication
def search
  @medication = Medication.search(params[:id])
end

def edit
    @medication = Medication.find(params[:id])
end

def create
  @medication = Medication.new(medication_params)

  @medication.save!
end

def update
  @medication.update(medication_params)
  respond_with(@medication)
end

def destroy
  @medication.destroy
  respond_with(@medication)
end

private
  def medication_params
    params.require(:medication).permit(:quantity, :expiration_date, :date_received, :vademecum_id)
  end
end
