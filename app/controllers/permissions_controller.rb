class PermissionsController < ApplicationController

  before_action :set_user, only: [:index, :edit, :update]

  def index
    @filterrific = initialize_filterrific(
      PermissionModule.eager_load(:permissions),
      params[:remote_form],
      persistence_id: false
    )
    @permission_modules = @filterrific.find.map{|per_mod| per_mod.permissions.map{|permission| @user.permission_users.build(sector: @user.sector, permission: permission)}}
      

    puts @permission_modules.count
    puts "====================="
  end

  def edit
    authorize Permission
    @filterrific = initialize_filterrific(
      PermissionModule.eager_load(:permissions),
      params[:remote_form],
      persistence_id: false
    )
    @permission_modules = @filterrific.find.map{|per_mod| {
      id: per_mod.id,
      name: per_mod.name,
      permissions: per_mod.permissions.map{|permission| @user.permission_users.build(sector: @user.sector, permission: permission)}}
    }
    # @permission_modules = @filterrific.find
    @enable_permissions = @user.permissions.pluck(:id)
  end

  def update
    puts params[:permission_users]
    # actualizar permisos teniendo en cuenta _destroy: true / false
    puts permission_params[:permissions_attributes]
    if permission_params[:permissions_attributes]
      permission_params[:permissions_attributes].each do |permiss|
        if permiss[:_destroy].persent? && permiss[:_destroy]
          @user.permission_users.destroy(sector: @user.sector, permission_id: permiss[:permission_id])
        elsif @user.permission_users.where(sector: @user.sector, permission_id: permiss[:permission_id]).any?
          @user.permission_users.create(sector: @user.sector, permission_id: permiss[:permission_id])
        end
      end
      # @user.update(user_params.except :id)
      # flash[:success] = "#{@user.full_name} se ha modificado correctamente."
      # format.html { redirect_to action: "show", id: @user.id }
    else
      # flash[:error] = "#{@user.full_name} no se ha podido modificar."
      # format.html { render :edit_permissions }
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def permission_params
    params.require(:permission_users).permit(
      permissions_attributes: [
        :permission_id,
        :_destroy
      ])
  end
end
