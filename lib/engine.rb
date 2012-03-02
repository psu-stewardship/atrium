require 'atrium'
require 'rails'
require 'action_controller'

module Atrium
  class Engine < Rails::Engine

    # Config defaults
    config.mount_at = '/'

    # Load rake tasks
    rake_tasks do
      Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)),'railties', '*.rake')).each do |railtie|
        load railtie
      end
    end

    # Check the gem config
    initializer "check config" do |app|
      # make sure mount_at ends with trailing slash
      config.mount_at += '/'  unless config.mount_at.last == '/'
    end

    # BlacklightHelper is needed by all helpers, so we inject it
    # into action view base here.
    initializer 'atrium.helpers' do |app|
      ActionView::Base.send :include, AtriumHelper
    end

    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end

  end
end
