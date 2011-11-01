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
      delete_or_assign_search_session_params

      extra_head_content << view_context.auto_discovery_link_tag(:rss, url_for(params.merge(:format => 'rss')), :title => "RSS for results")
      extra_head_content << view_context.auto_discovery_link_tag(:atom, url_for(params.merge(:format => 'atom')), :title => "Atom for results")
      extra_head_content << view_context.auto_discovery_link_tag(:unapi, unapi_url, {:type => 'application/xml',  :rel => 'unapi-server', :title => 'unAPI' })

      @extra_controller_params ||= {}
      if @atrium_exhibit
        filter_query_params = solr_search_params(@atrium_exhibit.filter_query_params)
        if filter_query_params[:fq]
          session_search_params = solr_search_params(params)
          if session_search_params[:fq]
            @extra_controller_params.merge!(:fq=>session_search_params[:fq].concat(filter_query_params[:fq]))
          end
        end
      end
      (@response, @document_list) = get_search_results(params,@extra_controller_params)
      #reset to settings before was merged with user params
      @extra_controller_params.merge!(:fq=>filter_query_params[:fq]) if ( filter_query_params && filter_query_params[:fq] )
      @filters = params[:f] || []
      search_session[:total] = @response.total unless @response.nil?

      respond_to do |format|
        format.html { save_current_search_params }
        format.rss  { render :layout => false }
        format.atom { render :layout => false }
      end
    end
  end
end

