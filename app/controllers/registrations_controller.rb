class RegistrationsController < Devise::RegistrationsController

  private

  def sign_up_params
    params.require(:user).permit(:username, :first_name, :last_name, :dni, :enrollment,
                                 :address, :phone, :sector, :email, :password,
                                 :password_confirmation, :gender)
  end

  def account_update_params
    params.require(:user).permit(:username, :first_name, :last_name, :dni, :enrollment,
                                 :address, :phone, :sector, :email, :password, :password_confirmation,
                                 :current_password, :gender)
  end
end
