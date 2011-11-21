class AtriumCollectionsController < ApplicationController

  include CatalogHelper
  include BlacklightHelper
  include Blacklight::SolrHelper
  include AtriumHelper
  include Atrium::SolrHelper
  include Atrium::CollectionsHelper

  layout 'atrium'

  before_filter :initialize_collection, :except=>[:index, :new]
  before_filter :atrium_html_head

  def new
    create
  end

  def create
    logger.debug("in create params: #{params.inspect}")
    @atrium_collection = Atrium::Collection.new
    @atrium_collection.save
    redirect_to :action => "edit", :id=>@atrium_collection.id
  end

  def update_embedded_search
    render :partial => "shared/featured_search", :locals=>{:content=>params[:content_type]}
  end

  def show
    #@atrium_collection = Atrium::Collection.find(params[:id])
    @showcase_navigation_data = get_showcase_navigation_data
    if(params[:showcase_number])
      @showcase = Atrium::Showcase.find(params[:showcase_number])
      @atrium_browse_page= Atrium::BrowsePage.with_selected_facets(@showcase.id,@showcase.class.name, params[:f]).first
    else
      @atrium_browse_page= Atrium::BrowsePage.with_selected_facets(@atrium_collection.id,@atrium_collection.class.name, params[:f]).first
      #get_atrium_browse_page(params[:showcase_number], params[:f]).first
    end

    if(params[:browse_page_id] && @atrium_browse_page.nil?)
      @atrium_browse_page = Atrium::BrowsePage.find(params[:browse_page_id])
    end
    logger.debug("Atrium Browse Page: #{@atrium_browse_page.inspect}")
    if @atrium_browse_page && !@atrium_browse_page.browse_page_items[:solr_doc_ids].nil?
      logger.debug("#{@atrium_browse_page.inspect}, #{@atrium_browse_page.browse_page_items[:solr_doc_ids]}")
      selected_document_ids = @atrium_browse_page.browse_page_items[:solr_doc_ids].split(',')
      logger.debug("Collection Selected Highlight: #{selected_document_ids.inspect}")
      @response, @documents = get_solr_response_for_field_values("id",selected_document_ids || [])
    end
    #puts "browse_level_navigation_data: #{@showcase_navigation_data.first.browse_levels.first.values.inspect}"
  end

  def edit
    #@atrium_collection = Atrium::Collection.find(params[:id])
    @showcase_navigation_data = get_showcase_navigation_data
  end

  def update
    @atrium_collection = Atrium::Collection.find(params[:id])
    respond_to do |format|
      if @atrium_collection.update_attributes(params[:atrium_collection])
        refresh_showcase
        flash[:notice] = 'Collection was successfully updated.'
        format.html  { render :action => "edit" }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @atrium_collection = Atrium::Collection.find(params[:id])
    @atrium_collection.destroy
    flash[:notice] = 'Collection deleted.'
    redirect_to catalog_index_path
  end
=begin
  # Just return nil for collection facet limit because we want to display all values for browse links
  def facet_limit_for(facet_field)
    return nil
  end
  helper_method :facet_limit_for

  # Returns complete hash of key=facet_field, value=limit.
  # Used by SolrHelper#solr_search_params to add limits to solr
  # request for all configured facet limits.
  def facet_limit_hash
    Blacklight.config[:facet][:limits]
  end
  helper_method :facet_limit_hash
=end
end

private

def refresh_showcase
  @showcase_navigation_data = get_showcase_navigation_data
end

def refresh_browse_level_label(atrium_collection)
  if params[:atrium_collection][:browse_levels_attributes]
    params[:atrium_collection][:browse_levels_attributes].each_pair do |index,values|
      if values[:solr_facet_name] && !values[:label]
        #reset label if facet changing and other label not supplied
        new_label = facet_field_labels[values[:solr_facet_name]]
        unless new_label.nil? || new_label.empty?
          atrium_collection.browse_levels.each_with_index do |browse_level,index|
            if browse_level.solr_facet_name == values[:solr_facet_name]
              atrium_collection.browse_levels[index].label = new_label
              atrium_collection.save!
              break
            end
          end
        end
      end
    end
  end
end