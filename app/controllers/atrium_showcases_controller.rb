class AtriumShowcasesController < ApplicationController

  include CatalogHelper
  include BlacklightHelper
  include Blacklight::SolrHelper
  include AtriumHelper
  include Atrium::SolrHelper
  include Atrium::CollectionsHelper

  before_filter :atrium_html_head
  layout 'atrium'

  before_filter :initialize_collection, :except=>[:index, :create]
  before_filter :atrium_html_head

  def new
    logger.debug("in create params: #{params.inspect}")
    @showcase = Atrium::Showcase.new
    respond_to do |format|
      format.html
    end
  end

  def create
    logger.debug("in create params: #{params.inspect}")
    @showcase = Atrium::Showcase.new(params[:atrium_showcase])

    @showcase.save
    logger.debug("in create params: #{@showcase.inspect}")
    #respond_to do |format|
    if @showcase.save
      @showcase.update_attributes(params[:atrium_showcase])

      flash[:notice] = 'Showcase was successfully created.'
      format.html { redirect_to :action => "edit", :id=>@showcase.id }
    end
    format.html { render :action => "new" }
    #end
  end

  def edit
    @showcase = Atrium::Showcase.find(params[:id])
    @atrium_collection = @showcase.collection
    @showcase_navigation_data = get_showcase_navigation_data
  end

  def update
    @showcase = Atrium::Showcase.find(params[:id])
    if @showcase.update_attributes(params[:atrium_showcase])
      #refresh_browse_level_label(@atrium_collection)
      flash[:notice] = 'Showcase was successfully updated.'
    end
    redirect_to :action => "edit", :collection_id=>@showcase.atrium_collection_id
  end

  def show
    @showcase= Atrium::Showcase.find(params[:id])
    @showcase_navigation_data = get_showcase_navigation_data
    logger.debug("Browse page: #{@showcase.browse_pages}")
    @atrium_browse_page=Atrium::BrowsePage.with_selected_facets(@showcase.id, @showcase.class.name, params[:f]).first
    if @atrium_browse_page && !@atrium_browse_page.browse_page_items[:solr_doc_ids].nil?
      logger.debug("#{@atrium_browse_page.inspect}, #{@atrium_browse_page.browse_page_items[:solr_doc_ids]}")
      selected_document_ids = @atrium_browse_page.browse_page_items[:solr_doc_ids].split(',')
      logger.debug("Collection Selected Highlight: #{selected_document_ids.inspect}")
      @response, @documents = get_solr_response_for_field_values("id",selected_document_ids || [])
    end
  end

  def destroy
    @showcase = Atrium::Showcase.find(params[:id])
    Atrium::Showcase.destroy(params[:id])
    flash[:notice] = 'Showcase'+params[:id] +'was deleted successfully.'
    redirect_to :controller=>"atrium_collections", :action => "edit", :id=>@showcase.atrium_collection_id
  end
end
