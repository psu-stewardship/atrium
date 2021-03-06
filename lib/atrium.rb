module Atrium
  require 'engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'application_controller'

  require 'atrium/version'
  require 'atrium/routes'

  require 'ckeditor-rails'
  require 'loggable'

  include Loggable


  def self.version
    Atrium::VERSION
  end

  def self.root
    @root ||= File.expand_path(File.dirname(File.dirname(__FILE__)))
  end

  # If you put this in your application's routes.rb, it will add the Atrium routes to the app.
  # The atrium generator puts this in routes.rb for you by default.
  # See {Atrium::Routes} for information about how to modify which routes are generated.
  # @example
  #   # in config/routes.rb
  #   MyAppName::Application.routes.draw do
  #     Blacklight.add_routes(self)
  #     HydraHead.add_routes(self)
  #     Atrium.add_routes(self)
  #   end
  def self.add_routes(router, options = {})
    Atrium::Routes.new(router, options).draw
  end

end

require 'atrium/application_helper.rb'
require 'atrium/collections_helper.rb'
require 'atrium/solr_helper.rb'
