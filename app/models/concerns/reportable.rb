module Reportable
  extend ActiveSupport::Concern

  included do
    has_many :report_products, class_name: 'ReportProductLine', as: :reportable
    has_many :products, through: :report_products

    accepts_nested_attributes_for :report_products, reject_if: ->(attributes){ attributes['product_id'].blank? }, allow_destroy: true

    validates_associated :report_products
  end
end