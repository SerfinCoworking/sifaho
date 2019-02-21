class SessionsController < Devise::SessionsController
  def create
    begin
      resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      redirect_to root_path
    rescue Net::LDAP::LdapError
      format.html {redirect_to new_user_session_path, :notice => $!.to_s}
      format.json {render json: $!.to_s}
    end
  end
end