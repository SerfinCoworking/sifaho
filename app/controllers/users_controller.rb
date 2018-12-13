class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :change_sector ]

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
        :sorted_by
      ],
    ) or return
    @users = @filterrific.find.page(params[:page]).per_page(15)
  end

  def change_sector
    authorize @user
    @sectors = @user.sectors

    respond_to do |format|  
      format.js
    end 
  end

  def update
    authorize @user

    respond_to do |format|
      if @user.update(user_params)
        flash[:success] = @user.full_name+" se ha modificado correctamente."
        format.js {render inline: "location.reload();" }
      else
        flash[:error] = @user.full_name+" no se ha podido modificar."
        format.js {render inline: "location.reload();" }
      end
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:sector_id)
  end
end 