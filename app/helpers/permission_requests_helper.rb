module PermissionRequestsHelper
  def permission_request_status_label(permission_request)
    if permission_request.nueva?
      return "info"
    elsif permission_request.terminada?
      return "success"
    end
  end
end
