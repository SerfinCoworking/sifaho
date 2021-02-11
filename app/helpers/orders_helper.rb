module OrdersHelper
  def highlight_row(an_id)
    if @highlight_row.present? && @highlight_row == an_id 
      return 'table-info'
    end
  end

  def sort_order_products(object, action)
    if ["new"].any? { |string| action.include? string }
      return object.order_products.build
    elsif ["edit", "update"].any? { |string| action.include? string }
      return object.order_products.joins(:product).order("products.name")
    elsif ["create"].any? { |string| action.include? string }
      return object.order_products
    end
  end
end