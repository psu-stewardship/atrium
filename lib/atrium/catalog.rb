require 'blacklight/catalog'

# Include this module into any of your Blacklight Catalog classes (ie. CatalogController) to add Atrium functionality
#
# This module will only work if you also include Blacklight::Catalog in the Controller you're extending.
# The atrium rails generator will create the CatalogController for you in app/controllers/catalog_controller.rb
# @example
# require 'blacklight/catalog'
# require 'atrium/catalog'
# class CustomCatalogController < ApplicationController
# include Blacklight::Catalog
# include Atrium::Catalog
# end
module Atrium::Catalog
  extend ActiveSupport::Concern
  include Blacklight::Catalog

  def index
    #put in atrium index code here
    if params[:save_exhibit_filter_button]
      puts "pressed save filter button"
      if params[:exhibit_id]
        redirect_to edit_atrium_exhibit_path(params[:exhibit_id])
      else
        redirect_to new_atrium_exhibit_path
      end
    else
      super
    end
  end
end

