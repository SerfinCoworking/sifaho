module ProductsHelper
  def product_status_label(product)
    if product.active?; return 'success'
    elsif product.inactive?; return 'danger'
    elsif product.merged?; return 'primary'
    end
  end
end
