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
  include BlacklightHelper

  def self.included(klass)
    klass.before_filter :initialize_collection
  end

  def show
    super
    if params[:atrium_collection_browse] || params[:atrium_exhibit_browse]
      @exhibit_navigation_data = get_exhibit_navigation_data
      
      #render :layout => "atrium"
      render "browse_show", :layout=> "atrium"
    end
  end

  def browse_show
    render :layout => "atrium"
  end

  def index
    stylesheet_links << ['atrium/atrium', {:media=>'all'}]

    #put in atrium index code here
    if params[:save_collection_filter_button]
      logger.debug("pressed save collection filter button")
      if @atrium_collection
        if !session[:folder_document_ids].blank?
          @atrium_collection.collection_items ||= Hash.new
          selected_document_ids = session[:folder_document_ids]
          collection_items={}
          collection_items[:solr_doc_ids]=selected_document_ids.join(',')
          #@atrium_collection.update_attributes(:collection_items=>collection_items)
          @atrium_collection.update_attributes(:filter_query_params=>collection_items)
          session[:folder_document_ids] = session[:copy_folder_document_ids]
          session[:copy_folder_document_ids]=nil
          logger.debug("@@atrium_collection: #{@atrium_collection.inspect},Selected Items: #{@atrium_collection.filter_query_params.inspect}, folders_selected: #{session[:folder_document_ids].inspect}")
        else
          filter_query_params = search_session.clone
          filter_query_params.delete(:save_collection_filter_button)
          filter_query_params.delete(:collection_id)
          filter_query_params.delete :action
          filter_query_params.delete :id
          filter_query_params.delete :controller
          filter_query_params.delete :utf8
          @atrium_collection.update_attributes(:filter_query_params=>filter_query_params)
        end
        redirect_to edit_atrium_collection_path(@atrium_collection.id)
      else
        redirect_to new_atrium_collection_path
      end
    elsif params[:save_exhibit_filter_button]
      params[:exhibit_id] ? exhibit_id = params[:exhibit_id] : exhibit_id = params[:edit_exhibit_filter]
      @exhibit = Atrium::Exhibit.find(exhibit_id) if exhibit_id
      logger.debug("pressed save exhibit filter button")
      if @exhibit
        if !session[:folder_document_ids].blank?
          selected_document_ids = session[:folder_document_ids]
          exhibit_items={}
          exhibit_items[:solr_doc_ids]=selected_document_ids.join(',')
          @exhibit.update_attributes(:filter_query_params=>exhibit_items)
          session[:folder_document_ids] = session[:copy_folder_document_ids]
          session[:copy_folder_document_ids]=nil
          logger.debug("exhibit: #{@exhibit.inspect},Selected Items: #{@exhibit.filter_query_params.inspect}, folders_selected: #{session[:folder_document_ids].inspect}")
        else
          filter_query_params = search_session.clone
          filter_query_params.delete(:save_exhibit_filter_button)
          filter_query_params.delete(:collection_id)
          filter_query_params.delete(:exhibit_id)
          filter_query_params.delete :action
          filter_query_params.delete :id
          filter_query_params.delete :controller
          filter_query_params.delete :utf8
          @exhibit.update_attributes(:filter_query_params=>filter_query_params)
        end
        redirect_to edit_atrium_exhibit_path(@exhibit.id)
      else
        redirect_to new_atrium_exhibit_path
      end
    elsif params[:save_browse_level_filter_button]
      params[:browse_level_id] ? browse_level_id = params[:browse_level_id] : browse_level_id = params[:edit_browse_level_filter]
      @browse_level = Atrium::BrowseLevel.find(browse_level_id) if browse_level_id
      logger.debug("pressed save browse level filter button")
      if @browse_level
        filter_query_params = search_session.clone
        filter_query_params.delete(:save_browse_level_filter_button)
        filter_query_params.delete(:collection_id)
        filter_query_params.delete(:browse_level_id)
        @browse_level.update_attributes(:filter_query_params=>filter_query_params)
        redirect_to edit_atrium_exhibit_path(@browse_level.atrium_exhibit_id)
      else
        redirect_to new_atrium_exhibit_path
      end
    else
      delete_or_assign_search_session_params

      extra_head_content << view_context.auto_discovery_link_tag(:rss, url_for(params.merge(:format => 'rss')), :title => "RSS for results")
      extra_head_content << view_context.auto_discovery_link_tag(:atom, url_for(params.merge(:format => 'atom')), :title => "Atom for results")
      extra_head_content << view_context.auto_discovery_link_tag(:unapi, unapi_url, {:type => 'application/xml',  :rel => 'unapi-server', :title => 'unAPI' })

      @extra_controller_params = {}
      if params[:browse_level_id]
        @browse_level = Atrium::BrowseLevel.find(params[:browse_level_id]) 
        @exhibit = @browse_level.exhibit if @browse_level
        @atrium_collection = @exhibit.collection if @exhibit
      end

      #do not mixin whatever level I am on if I am editing the settings
      collection = @atrium_collection unless params[:edit_collection_filter]
      exhibit = @exhibit unless params[:edit_exhibit_filter] || params[:edit_collection_filter]
      browse_level = @browse_level unless params[:edit_exhibit_filter] || params[:edit_collection_filter] || params[:edit_browse_level_filter]
      logger.debug("collection is: #{collection.inspect}")
      logger.debug("exhibit is: #{exhibit.inspect}")
      logger.debug("browse level is: #{browse_level.inspect}")
      @extra_controller_params = prepare_extra_controller_params_for_collection_query(collection,exhibit,browse_level,params,@extra_controller_params) if collection || exhibit || browse_level
      logger.debug("params before search are: #{params.inspect}")
      logger.debug("extra params before search are: #{@extra_controller_params.inspect}")
      (@response, @document_list) = get_search_results(params,@extra_controller_params)
      #reset to settings before was merged with user params
      @extra_controller_params = reset_extra_controller_params_after_collection_query(collection,exhibit,browse_level,@extra_controller_params) if collection || exhibit || browse_level
      @filters = params[:f] || []
      search_session[:total] = @response.total unless @response.nil?

      respond_to do |format|
        format.html { save_current_search_params unless params[:edit_exhibit_filter] ||  params[:edit_collection_filter] || params[:edit_browse_level_filter]}
        format.rss  { render :layout => false }
        format.atom { render :layout => false }
      end
    end
  end
end

