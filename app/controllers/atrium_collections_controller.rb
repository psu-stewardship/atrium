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

  def home_page_text_config
    @atrium_collection= Atrium::Collection.find(params[:id])
  end

  def show
    #@atrium_collection = Atrium::Collection.find(params[:id])
    @exhibit_navigation_data = get_exhibit_navigation_data
    if(params[:collection_number])
      @collection = Atrium::Exhibit.find(params[:collection_number])
      @atrium_showcase= Atrium::Showcase.with_selected_facets(@collection.id,@collection.class.name, params[:f]).first
    else
      @atrium_showcase= Atrium::Showcase.with_selected_facets(@atrium_collection.id,@atrium_collection.class.name, params[:f]).first
      #get_atrium_showcase(params[:collection_number], params[:f]).first
    end

    if(params[:showcase_id] && @atrium_showcase.nil?)
      @atrium_showcase = Atrium::Showcase.find(params[:showcase_id])
    end
    logger.debug("Atrium Browse Page: #{@atrium_showcase.inspect}")
    if @atrium_showcase && !@atrium_showcase.showcase_items[:solr_doc_ids].nil?
      logger.debug("#{@atrium_showcase.inspect}, #{@atrium_showcase.showcase_items[:solr_doc_ids]}")
      selected_document_ids = @atrium_showcase.showcase_items[:solr_doc_ids].split(',')
      logger.debug("Collection Selected Highlight: #{selected_document_ids.inspect}")
      @response, @documents = get_solr_response_for_field_values("id",selected_document_ids || [])
    end
    #puts "browse_level_navigation_data: #{@exhibit_navigation_data.first.browse_levels.first.values.inspect}"
  end

  def edit
    #@atrium_collection = Atrium::Collection.find(params[:id])
    @exhibit_navigation_data = get_exhibit_navigation_data
  end

  def update
    @atrium_collection = Atrium::Collection.find(params[:id])
    respond_to do |format|
      if @atrium_collection.update_attributes(params[:atrium_collection])
        refresh_collection
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

def refresh_collection
  @exhibit_navigation_data = get_exhibit_navigation_data
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
