class PermissionsController < ApplicationController

  before_action :set_user, only: [:index, :edit, :update]

  def index
    @filterrific = initialize_filterrific(
      PermissionModule.eager_load(:permissions),
      params[:remote_form],
      persistence_id: false
    )
    @permission_modules = @filterrific.find
    @sector = params[:remote_form].present? && params[:remote_form][:sector].present? ? Sector.find(params[:remote_form][:sector]) : @user.sector
    @enable_permissions = @user.permission_users.where(sector: @sector).pluck(:permission_id)
  end

  def edit
    authorize Permission
    @filterrific = initialize_filterrific(
      PermissionModule.eager_load(:permissions),
      params[:remote_form],
      persistence_id: false
    )
    @permission_modules = @filterrific.find
    @sector = params[:remote_form].present? ? Sector.find(params[:remote_form][:sector]) : @user.sector
    @enable_permissions = @user.permission_users.where(sector: @sector).pluck(:permission_id)
    @sectors = Sector.includes(:establishment)
                     .order('establishments.name ASC', 'sectors.name ASC')
                     .where.not(id: @user.sectors.pluck(:id))
  end

  def update
    respond_to do |format|
      begin
        @user.update!(permission_params)
        format.html { redirect_to users_admin_url(@user) }
      rescue
        flash[:error] = "No se pudo actualizar los permisos del usuario #{@user.full_name}"
        @filterrific = initialize_filterrific(
          PermissionModule.eager_load(:permissions),
          params[:remote_form],
          persistence_id: false
        )
        @permission_modules = @filterrific.find
        @sector = params[:remote_form].present? ? Sector.find(params[:remote_form][:sector]) : @user.sector
        @enable_permissions = @user.permission_users.where(sector: @sector).pluck(:permission_id)
        format.html { render :edit }
      end
    end
  end

  private
  def set_user
    @user = User.eager_load(:sectors).find(params[:id])
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
