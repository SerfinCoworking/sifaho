class TempusDominusInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    # FIX Cocoon:
    # utiliza el nombre del input como id del elemento wrapper
    # el problema es que el elemento "div" no soporta los siguientes caracteres "[" "]"
    # por lo tanto los reemplzamos con "_"
    target = "#{object_name}_#{attribute_name}".gsub("[", "_").gsub("]", "_")
    template.content_tag(:div, class: 'input-group date', data: { target_input: 'nearest' }, id: target) do
      template.concat @builder.text_field(attribute_name, input_html_options)
      template.concat div_button
    end
  end

  def input_html_options
    super.merge({class: 'form-control datetimepicker-input'})
  end

  def div_button
    # FIX Cocoon:
    # utiliza el nombre del input como id del elemento wrapper
    # el problema es que el elemento "div" no soporta los siguientes caracteres "[" "]"
    # por lo tanto los reemplzamos con "_"
    target = "##{object_name}_#{attribute_name}".gsub("[", "_").gsub("]", "_")
    template.content_tag(:div, class: 'input-group-append', data: {target: target, toggle: 'datetimepicker'} ) do
      template.concat span_button
    end
  end

  def span_button
    template.content_tag(:span, class: 'input-group-btn') do
      template.concat calendar_button
    end
  end

  def calendar_button
    template.button_tag(class: 'btn btn-primary', :type => 'button') do
      template.concat icon_table
    end
  end

  def icon_remove
    "<i class='fa fa-times'></i>".html_safe
  end

  def icon_table
    "<i class='fa fa-calendar'></i>".html_safe
  end
end
