Rails.application.routes.draw do

  # Routes for the Atrium application are defined in Atrium::Routes
  #
  # These routes can be injected into your Rails application by adding
  #     Atrium.add_routes(self)
  # to the application's ./config/routes.rb. The injected routes can be 
  # customized as well, e.g.:
  #     Atrium.add_routes(self, :only => [:collection]) # will only load collection routes
  #     Atrium.add_routes(self, :except => [:catalog]) # will not load catalog routes
end

