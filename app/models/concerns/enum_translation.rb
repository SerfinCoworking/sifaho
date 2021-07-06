module EnumTranslation
  extend ActiveSupport::Concern

  included do
    # When creating a new report: making sure at least one product exists
    def self.human_enum_name(enum_name, enum_value)
      I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}")
    end
  end
end
