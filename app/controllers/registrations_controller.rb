class RegistrationsController < Devise::RegistrationsController

  private

  def sign_up_params
    params.require(:user).permit(:username, :password, :password_confirmation, :sector,
                                  profile_attributes: [
                                    :id, :first_name, :last_name, :dni, :date_of_birth,
                                    :enrollment, :address, :email, :sex
                                  ])
  end

  def account_update_params
    params.require(:user).permit(:username, :password, :password_confirmation, :sector,
                                  profile_attributes: [
                                    :id, :first_name, :last_name, :dni, :date_of_birth,
                                    :enrollment, :address, :email, :sex
                                  ])
  end
end
