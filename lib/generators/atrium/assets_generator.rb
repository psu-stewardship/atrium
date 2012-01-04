# -*- encoding : utf-8 -*-
# Copy Atrium assets to public folder in current app.
# If you want to do this on application startup, you can
# add this next line to your one of your environment files --
# generally you'd only want to do this in 'development', and can
# add it to environments/development.rb:
#       require File.join(Atrium.root, "lib", "generators", "atrium", "assets_generator.rb")
#       Atrium::Assets.start(["--force", "--quiet"])


# Need the requires here so we can call the generator from environment.rb
# as suggested above.
require 'rails/generators'
require 'rails/generators/base'
module Atrium
  class Assets < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def assets
      unless IO.read("app/assets/stylesheets/application.css").include?("Atrium")
        insert_into_file "app/assets/stylesheets/application.css", :before => "*/" do
  %q{
  * Required by Atrium:
  *= require 'colorbox'
  *= require 'atrium/chosen'
  *= require 'atrium/atrium'
  }
      end
    end

      unless IO.read("app/assets/javascripts/application.js").include?('atrium/atrium')
        insert_into_file "app/assets/javascripts/application.js", :after => "//= require jquery_ujs" do
%q{
//
// Required by Atrium
//= require atrium/atrium}
        end
      end

      directory("../../../../app/assets/images/atrium", "app/assets/images/atrium")
    end
  end
end

