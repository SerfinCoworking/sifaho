class SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, :only => :create
  require 'timeout'
  require 'socket'

  def create
    begin
      if ping("192.168.20.112")
        resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
        set_flash_message(:notice, :signed_in) if is_navigational_format?
        resource.password = params[:user][:password]
        resource.save!
      else
        user = User.find_by_username(params[:user][:username])
        if user.present? && user.valid_password?(params[:user][:password])
          sign_in(:user, user)
        else
          raise ArgumentError, 'Usuario o contraseña incorrectos.'
        end
      end
      redirect_to root_path
    rescue Net::LDAP::Error
      respond_to do |format|
        format.html {redirect_to new_user_session_path, :notice => $!.to_s}
        format.json {render json: $!.to_s}
      end
    rescue ArgumentError => e
      respond_to do |format|
        flash[:alert] = e.message
        format.html { redirect_to new_user_session_path }
      end
    end
  end

  private
  def ping(host)
    begin
      Timeout.timeout(5) do 
        s = TCPSocket.new(host, 'echo')
        s.close
        return true
      end
    rescue Errno::ECONNREFUSED 
      return true
    rescue Timeout::Error, Errno::ENETUNREACH, Errno::EHOSTUNREACH
      return false
    end
  end
end