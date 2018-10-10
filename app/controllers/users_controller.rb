class UsersController < ApplicationController
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
    @users = @filterrific.find.page(params[:page]).per_page(8)
  end
end 