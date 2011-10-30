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
  include Atrium::SolrHelper

  def self.included(klass)
    klass.before_filter :initialize_exhibit
  end

  def index
    #put in atrium index code here
    if params[:save_exhibit_filter_button]
      puts "pressed save filter button"
      puts "search session: #{solr_search_params(session[:search]).inspect}"
      if @atrium_exhibit
        filter_query_params = search_session.clone
        filter_query_params.delete(:save_exhibit_filter_button)
        filter_query_params.delete(:exhibit_id)
        @atrium_exhibit.update_attributes(:filter_query_params=>filter_query_params)
        redirect_to edit_atrium_exhibit_path(@atrium_exhibit.id)
      else
        redirect_to new_atrium_exhibit_path
      end
    else
      super
    end
  end
end

