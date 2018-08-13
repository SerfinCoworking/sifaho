# -*- coding: utf-8 -*-

require 'filterrific/param_set'

require 'filterrific/action_controller_extension'
require 'filterrific/active_record_extension'

module Filterrific
  class EngineApi < ::Rails::Engine

TODO: Since this is API only, I don't think we need an engine!
    # It's an engine so that we can add javascript and image assets
    # to the asset pipeline.

    isolate_namespace Filterrific

    ActiveSupport.on_load :action_controller do
      include Filterrific::ActionControllerExtension
    end

    ActiveSupport.on_load :active_record do
      extend Filterrific::ActiveRecordExtension
    end

  end
end
