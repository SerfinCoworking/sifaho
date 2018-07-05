class ProfilesController < ApplicationController
  after_action :verify_authorized

  def edit
    @profile = current_user.profile
    authorize @profile
  end

  def update
    @profile = current_user.profile
    authorize @profile

    if @profile.update(profile_params)
      flash[:success] = "Tu perfil se ha modificado correctamente."
      redirect_to request.referrer
    else
      flash[:error] = "Tu perfil no se ha podido modificar."
      redirect_to request.referrer
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :dni, :date_of_birth,
                                    :enrollment, :address, :email, :sex)
  end
end
