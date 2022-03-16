require_relative 'boot'

require 'rails/all'
require 'active_storage/engine'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sifaho
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.exceptions_app = self.routes # a Rack Application

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.time_zone = 'Buenos Aires'
    config.active_record.default_timezone = :utc

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i[get post options]
      end
    end

    config.middleware.use Rack::Attack

    config.generators.system_tests = nil

    # config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.enforce_available_locales = true
    # Permitted locales available for the application
    I18n.available_locales = %i[en es]
    config.i18n.default_locale = :es

    config.autoload_paths += Dir[Rails.root.join('app', 'jobs', '*/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '*/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'mailers', '*/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'policies', '*/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'controllers', '*/')]
    config.autoload_paths << Rails.root.join('lib')
    config.paths['config/routes.rb'] = Dir[Rails.root.join('config/routes/*.rb')]
  end
end
