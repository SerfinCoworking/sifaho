class PermissionsController < ApplicationController

  before_action :set_user, only: [:index, :edit, :update]

  def index
    @filterrific = initialize_filterrific(
      PermissionModule.eager_load(:permissions),
      params[:remote_form],
      persistence_id: false
    )
    @permission_modules = @filterrific.find
    @enable_permissions = @user.permissions.pluck(:id)
  end

  def edit
    authorize Permission
    @filterrific = initialize_filterrific(
      PermissionModule.eager_load(:permissions),
      params[:remote_form],
      persistence_id: false
    )
    @permission_modules = @filterrific.find
    @enable_permissions = @user.permissions.pluck(:id)
  end

  def update
    @user.update(permission_params)
    respond_to do |format|
      format.html { redirect_to users_admin_url(@user) }
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def permission_params
    params.require(:permission).permit(
      permission_users_attributes: [
        :id,
        :permission_id,
        :sector_id,
        :_destroy
      ])
  end
end
