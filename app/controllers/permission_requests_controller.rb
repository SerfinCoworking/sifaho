class PermissionRequestsController < ApplicationController
  before_action :set_permission_request, only: [:show, :edit, :update, :destroy, :end]

  # GET /permission_requests
  # GET /permission_requests.json
  def index
    authorize PermissionRequest
    @filterrific = initialize_filterrific(
      PermissionRequest.order(created_at: :desc),
      params[:filterrific],
      select_options: {
        sorted_by: PermissionRequest.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :sorted_by,
        :search_name,
      ],
    ) or return
    @permission_requests = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /permission_requests/1
  # GET /permission_requests/1.json
  def show
    @user = @permission_request.user
    @sectors = Sector.joins(:establishment).pluck(:id, :name, "establishments.name")
    if @user.has_role? :admin
      @roles = Role.all.order(:name).pluck(:id, :name)
    else
      @roles = Role.where.not(name: "admin").order(:name).pluck(:id, :name)
    end
  end

  # GET /permission_requests/new
  def new
    @permission_request = PermissionRequest.new
  end

  # GET /permission_requests/1/edit
  def edit
  end

  # POST /permission_requests
  # POST /permission_requests.json
  def create
    @permission_request = PermissionRequest.new(permission_request_params)
    @permission_request.user = current_user
    
    respond_to do |format|
      if @permission_request.save
        format.html { redirect_to root_url, notice: 'La solicitud de permisos de ha enviado correctamente.' }
        format.json { render :show, status: :created, location: @permission_request }
      else
        format.html { render :new }
        format.json { render json: @permission_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permission_requests/1
  # PATCH/PUT /permission_requests/1.json
  def update
    respond_to do |format|
      if @permission_request.update(permission_request_params)
        format.html { redirect_to @permission_request, notice: 'Permission request was successfully updated.' }
        format.json { render :show, status: :ok, location: @permission_request }
      else
        format.html { render :edit }
        format.json { render json: @permission_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permission_requests/1
  # DELETE /permission_requests/1.json
  def destroy
    @permission_request.destroy
    respond_to do |format|
      format.html { redirect_to permission_requests_url, notice: 'Permission request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def end
    respond_to do |format|
      if @permission_request.terminada!
        format.html { redirect_to @permission_request, notice: 'Se marcó la solicitud como terminada.'}
      else
        format.html { redirect_to @permission_request, notice: 'Hubo un problema con la solicitud.'}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permission_request
      @permission_request = PermissionRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def permission_request_params
      params.require(:permission_request).permit(:establishment, :sector, :role,:observation)
    end
end
