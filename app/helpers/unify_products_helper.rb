module UnifyProductsHelper
  def unify_product_status_label(order)
    if order.pending?; return 'secondary'
    elsif order.merged?; return 'success'
    end
  end
end
