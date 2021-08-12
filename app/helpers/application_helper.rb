module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type
      when "success"
        "alert-success"   # Green
      when "error"
        "alert-danger"    # Red
      when "alert"
        "alert-warning"   # Yellow
      when "notice"
        "alert-info"      # Blue
      else
        flash_type.to_s
    end
  end

  def paginate(collection, params= {})
    will_paginate collection, params.merge(renderer: BootstrapPagination::Rails, previous_label: 'Atras', next_label: 'Siguiente')
  end

  def active_class(link_path)
    return 'active' if params[:controller] == link_path
  end

  def active_class_folder(folder_name)
    return 'active' if params[:controller].start_with?(folder_name)
  end

  def controller_path
    return params[:controller]
  end

  def active_action(link_path)
    return 'active' if params[:action] == link_path
  end

  def active_action_and_controller(action_name, a_controller_name)
    return 'active' if params[:action] == action_name && controller_name == a_controller_name
  end

  def order_status_label(an_order)
    if an_order.is_a?(Prescription)
      prescription_status_label(an_order)
    elsif an_order.is_a?(InternalOrder)
      internal_status_label(an_order)
    elsif an_order.is_a?(ExternalOrder)
      ordering_status_label(an_order)
    end
  end

  def google_map(center)
    "https://maps.googleapis.com/maps/api/staticmap?center=#{center}&size=300x300&zoom=17?key=AIzaSyAC45udxXu_GFnHefBcBLJcRHdHGFDIru4"
  end
end
