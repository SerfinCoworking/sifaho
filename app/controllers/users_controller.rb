class UsersController < ApplicationController
  before_action :set_user, only: %I[show update change_sector edit_permissions update_permissions adds_sector removes_sector ]

  def index
    authorize User
    @filterrific = initialize_filterrific(
      User,
      params[:filterrific],
      select_options: {
        with_status: InternalOrder.options_for_status
      },
      persistence_id: false,
      default_filter_params: { sorted_by: 'created_at_desc' },
      available_filters: [
        :search_username,
        :search_by_fullname,
        :sorted_by
      ],
    ) or return
    @users = @filterrific.find.page(params[:page]).per_page(14)
  end

  def show
    authorize @user
  end

  def change_sector
    authorize @user
    @sectors = @user.sectors.joins(:establishment).pluck(:id, :name, "establishments.name")

    respond_to do |format|  
      format.js
    end
  end

  def edit_permissions
    authorize @user
    @sectors = Sector.joins(:establishment).pluck(:id, :name, "establishments.name")
    @enabled_sectors = @user.sectors.joins(:establishment).pluck(:id, :name, "establishments.name")
    @professional = Professional.new
    if @user.has_role? :admin
      @roles = Role.all.order(:name).pluck(:id, :name)
    else
      @roles = Role.where.not(name: "admin").order(:name).pluck(:id, :name)
    end
  end

  def update_permissions
    authorize @user

    respond_to do |format|
      if @user.update(user_params.except :id)
        flash[:success] = "#{@user.full_name} se ha modificado correctamente."
        format.html { redirect_to action: "show", id: @user.id }
      else
        flash[:error] = "#{@user.full_name} no se ha podido modificar."
        format.html { render :edit_permissions }
      end
    end
  end

  def update
    authorize @user

    respond_to do |format|
      if @user.update(user_params)
        flash[:success] = "Ahora estás en #{@user.sector_name} #{@user.sector_establishment_short_name}"
        format.js {render inline: "location.reload();" }
      else
        flash[:error] = "No se ha podido modificar el sector."
        format.js {render inline: "location.reload();" }
      end
    end
  end

  def adds_sector
    @sector = Sector.find(params[:remote_form][:sector])
    @user.sectors << @sector
    @user.sector = @sector if @user.sector_id.nil?
    @user.save
    @sectors = Sector.includes(:establishment)
                     .order('establishments.name ASC', 'sectors.name ASC')
                     .where.not(id: @user.sectors.pluck(:id))
  end

  def removes_sector
    @user.user_sectors.where(sector_id: params[:sector_id]).first.destroy
    @user.permission_users.where(sector_id: params[:sector_id]).destroy_all

    @user.update!(sector: @user.sectors.first) if @user.sector_id == params[:sector_id].to_i

    @sectors = Sector.includes(:establishment)
                     .order('establishments.name ASC', 'sectors.name ASC')
                     .where.not(id: @user.sectors.pluck(:id))
    @sector = @user.sector if @user.sector.present?
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:id, :sector_id, sector_ids: [], role_ids: [])
  end
end
