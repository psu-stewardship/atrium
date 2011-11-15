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
    stylesheet_links << ['atrium/atrium', {:media=>'all'}]

    #put in atrium index code here
    if params[:save_exhibit_filter_button]
      logger.debug("pressed save exhibit filter button")
      if @atrium_exhibit
        filter_query_params = search_session.clone
        filter_query_params.delete(:save_exhibit_filter_button)
        filter_query_params.delete(:exhibit_id)
        @atrium_exhibit.update_attributes(:filter_query_params=>filter_query_params)
        redirect_to edit_atrium_exhibit_path(@atrium_exhibit.id)
      else
        redirect_to new_atrium_exhibit_path
      end
    elsif params[:save_showcase_filter_button]
      params[:showcase_id] ? showcase_id = params[:showcase_id] : showcase_id = params[:edit_showcase_filter]
      @showcase = Atrium::Showcase.find(showcase_id) if showcase_id
      logger.debug("pressed save showcase filter button")
      if @showcase
        filter_query_params = search_session.clone
        filter_query_params.delete(:save_showcase_filter_button)
        filter_query_params.delete(:exhibit_id)
        filter_query_params.delete(:showcase_id)
        @showcase.update_attributes(:filter_query_params=>filter_query_params)
        redirect_to edit_atrium_showcase_path(@showcase.id)
      else
        redirect_to new_atrium_showcase_path
      end
    elsif params[:save_browse_level_filter_button]
      params[:browse_level_id] ? browse_level_id = params[:browse_level_id] : browse_level_id = params[:edit_browse_level_filter]
      @browse_level = Atrium::BrowseLevel.find(browse_level_id) if browse_level_id
      logger.debug("pressed save browse level filter button")
      if @browse_level
        filter_query_params = search_session.clone
        filter_query_params.delete(:save_browse_level_filter_button)
        filter_query_params.delete(:exhibit_id)
        filter_query_params.delete(:browse_level_id)
        @browse_level.update_attributes(:filter_query_params=>filter_query_params)
        redirect_to edit_atrium_showcase_path(@browse_level.atrium_showcase_id)
      else
        redirect_to new_atrium_showcase_path
      end
    else
      delete_or_assign_search_session_params

      extra_head_content << view_context.auto_discovery_link_tag(:rss, url_for(params.merge(:format => 'rss')), :title => "RSS for results")
      extra_head_content << view_context.auto_discovery_link_tag(:atom, url_for(params.merge(:format => 'atom')), :title => "Atom for results")
      extra_head_content << view_context.auto_discovery_link_tag(:unapi, unapi_url, {:type => 'application/xml',  :rel => 'unapi-server', :title => 'unAPI' })

      @extra_controller_params ||= {}
      @browse_level = Atrium::BrowseLevel.find(params[:browse_level_id]) if params[:browse_level_id]
      @extra_controller_params = prepare_extra_controller_params_for_exhibit_query(@atrium_exhibit,@showcase,@browse_level,params,@extra_controller_params) if @atrium_exhibit || @showcase || @browse_level
      puts "on search exhibit is: #{@atrium_exhibit.inspect}"
      puts "on search showcase is: #{@showcase.inspect}"
      puts "on search browse_level is: #{@browse_level.inspect}"
      puts "on search params: #{params.inspect}"
      puts "on search extra params: #{@extra_controller_params.inspect}"
      (@response, @document_list) = get_search_results(params,@extra_controller_params)
      #reset to settings before was merged with user params
      @extra_controller_params = reset_extra_controller_params_after_exhibit_query(@atrium_exhibit,@showcase,@browse_level,@extra_controller_params) if @atrium_exhibit || @showcase || @browse_level
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

