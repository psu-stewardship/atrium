# -*- encoding : utf-8 -*-
require 'rails/generators'
require 'rails/generators/migration'     

# require "generators/blacklight/blacklight_generator"

module Atrium
  class AtriumGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    
    source_root File.expand_path('../templates', __FILE__)
    
    argument     :model_name, :type => :string , :default => "user"
    
    desc """
  This generator makes the following changes to your application:
    1. Creates several database migrations if they do not exist in /db/migrate
    2. Adds additional mime types to you application in the file '/config/initializers/mime_types.rb'   
    3. Creates config/solr.yml which you may need to modify to tell atrium where to find fedora & solr
    6. Creates a number of role_map config files that are used in the placeholder user roles implementation 
  Enjoy!

         """
    #
    # Config Files & Initializers
    #     
    # Copy all files in templates/config directory to host config
    def create_configuration_files
      # Initializers
      #copy_file "config/initializers/fedora_config.rb", "config/initializers/fedora_config.rb"
      #copy_file "config/initializers/hydra_config.rb", "config/initializers/hydra_config.rb"
      #copy_file "config/initializers/blacklight_config.rb", "config/initializers/blacklight_config.rb"
      
      # Role Mappings
      copy_file "config/role_map_cucumber.yml", "config/role_map_cucumber.yml"
      copy_file "config/role_map_development.yml", "config/role_map_development.yml"
      copy_file "config/role_map_production.yml", "config/role_map_production.yml"
      copy_file "config/role_map_test.yml", "config/role_map_test.yml"
      
      # Solr Mappings
      #copy_file "config/solr_mappings.yml", "config/solr_mappings.yml"
      
      # Fedora & Solr YAML files
      #copy_file "config/fedora.yml", "config/fedora.yml"
      copy_file "config/solr.yml", "config/solr.yml"
      
      # Fedora & Solr Config files
      #directory "fedora_conf"
      #directory "solr_conf"
      ## directory "../../../../fedora_conf", "fedora_conf"
      ## directory "../../../../solr_conf", "solr_conf"
    end

    # Copy all files in templates/public/ directory to public/
    # Call external generator in AssetsGenerator, so we can
    # leave that callable seperately too.
    def copy_public_assets
      generate "atrium:assets"
    end

    # Register mimetypes required by hydra-head
    def add_mime_types
      puts "Updating Mime Types"
      insert_into_file "config/initializers/mime_types.rb", :before => 'Mime::Type.register_alias "text/plain", :refworks_marc_txt' do <<EOF
Mime::Type.register_alias "text/html", :textile
Mime::Type.register_alias "text/html", :inline

EOF
      end
    end
  
    #
    # Migrations
    #

    # Implement the required interface for Rails::Generators::Migration.
    # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
    def self.next_migration_number(dirname)
      unless @previous_migration_nr
        if ActiveRecord::Base.timestamped_migrations
          @previous_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        else
          @previous_migration_nr = "%.3d" % (current_migration_number(dirname) + 1).to_i
        end
      else
        @previous_migration_nr +=1 
      end
      @previous_migration_nr.to_s
    end

    # Add Atrium behaviors and Filters to ApplicationHelper
    def inject_atrium_helper_behavior
      insert_into_file "app/helpers/application_helper.rb", :after => 'module ApplicationHelper' do
        "\n  # Adds a atrium exhibits behaviors into the application helper \n " +        
          "  include Atrium::ExhibitsHelper\n" +
          "  include CatalogHelper\n"
      end
    end

    # Add Hydra to the application controller
    def inject_atrium_controller_behavior    
      inject_into_class "app/controllers/application_controller.rb", "ApplicationController" do
        "  # Adds Atrium behaviors into the application controller \n " +        
          "  include Atrium::Controller\n"
          
      end
    end

    # Inject call to Atrium.add_routes in config/routes.rb
    def inject_atrium_routes
      puts "here"
      insert_into_file "config/routes.rb", :after => 'Blacklight.add_routes(self)' do
        "\n  # Add Hydra routes.  For options, see API docs for HydraHead.routes"
        "\n  Atrium.add_routes(self)"
      end
    end

    # Setup the database migrations
    def copy_migrations
      # Can't get this any more DRY, because we need this order.
      better_migration_template "create_atrium_exhibits.rb"
      better_migration_template "create_atrium_search_facets.rb"
      better_migration_template "create_atrium_browse_sets.rb"
      better_migration_template "create_atrium_showcases.rb"
      better_migration_template "create_atrium_showcase_items.rb"
      better_migration_template "create_atrium_showcase_facet_selections.rb"
      better_migration_template "create_atrium_browse_levels.rb"
    end

    private  
  
    def better_migration_template (file)
      begin
        migration_template "migrations/#{file}", "db/migrate/#{file}"
        sleep 1 # ensure scripts have different time stamps
      rescue
        puts "  \e[1m\e[34mMigrations\e[0m  " + $!.message
      end
    end
  end # AtriumGenerator
end # Atrium
