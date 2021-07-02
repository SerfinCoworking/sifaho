module Reportable
  extend ActiveSupport::Concern

  included do
    has_many :report_products, class_name: 'ReportProductLine', as: :reportable
    has_many :products, through: :report_products

    accepts_nested_attributes_for :report_products, reject_if: ->(attributes){ attributes['product_id'].blank? }, allow_destroy: true

    validates_associated :report_products
    validate :at_least_one_report_product

    private

    # When creating a new report: making sure at least one product exists
    def at_least_one_report_product
      return errors.add :base, 'debe tener al menos un producto' unless report_products.length > 0
    end
  end
end
