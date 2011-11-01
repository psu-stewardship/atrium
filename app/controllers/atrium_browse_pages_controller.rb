class AtriumBrowsePagesController < ApplicationController

  include Blacklight::SolrHelper
  include Atrium::ExhibitsHelper
  include Atrium::SolrHelper
  include CatalogHelper
  include BlacklightHelper
  include AtriumHelper

  before_filter :atrium_html_head
  layout 'atrium'

  before_filter :initialize_exhibit

  def index
    logger.debug("in Index params: #{params.inspect}")
    @showcase = Atrium::Showcase.find(params[:atrium_showcase_id])
    @showcase_navigation_data = get_showcase_navigation_data
    logger.debug("Showcase: #{@showcase.inspect}, Browse level:#{@showcase.browse_levels.inspect}")
    redirect_to atrium_exhibit_path(:edit_browse_page=>true,:id=>@showcase.atrium_exhibit_id, :showcase_number=>@showcase.id)
    #render :partial => 'atrium_exhibits/navigation_browse_levels', :locals=>{:showcase_number=>showcase.set_number, :browse_levels=>showcase.browse_levels, :browse_facets=>showcase.browse_facet_names}
  end

  def new
    @atrium_browse_page = Atrium::BrowsePage.new
    respond_to do |format|
      format.html
    end
  end

  def create
    logger.debug("in create params: #{params.inspect}")
    @atrium_browse_page= top_level_browse_page(params[:atrium_browse_page][:atrium_showcase_id])
    if  @atrium_browse_page.nil?
      @atrium_browse_page = Atrium::BrowsePage.new(params[:atrium_browse_page])
      @atrium_browse_page.browse_page_items ||= Hash.new
      logger.info("atrium_browse_page = #{@atrium_browse_page.inspect}")
      @atrium_browse_page.save
    end
    #@atrium_browse_page = Atrium::BrowsePage.new(params[:atrium_browse_page])
    #@atrium_browse_page.browse_page_items ||= Hash.new
    logger.info("atrium_browse_page = #{@atrium_browse_page.inspect}")
    redirect_to :action => "configure_browse_page" , :id=>@atrium_browse_page.id, :atrium_showcase_id=>@atrium_browse_page.atrium_showcase_id
  end

  def edit
    @atrium_browse_page = Atrium::BrowsePage.find(params[:id])
  end

  def update
     @atrium_browse_page = Atrium::BrowsePage.find(params[:id])
    if @atrium_browse_page.update_attributes(params[:atrium_browse_page])
      #refresh_browse_level_label(@atrium_exhibit)
      flash[:notice] = 'Browse was successfully updated.'
    end
    redirect_to :action => "edit", :id=>@atrium_browse_page.id

  end

  def show
    @atrium_browse_page = Atrium::BrowsePage.find(params[:id])
    selected_document_ids = session[:folder_document_ids]
    session[:folder_document_ids] = session[:copy_folder_document_ids]
    logger.debug("Selected Highlight: #{selected_document_ids.inspect}, folders_selected: #{session[:folder_document_ids].inspect}")
    @response, @documents = get_solr_response_for_field_values("id",selected_document_ids || [])
    render :layout => false, :locals=>{:selected_document_ids=>selected_document_ids}
  end

  def destroy

  end

  def configure_browse_page
    logger.debug("in configure_browse_page params: #{params.inspect}")
    #@atrium_browse_page = Atrium::BrowsePage.find(params[:id])
    @showcase = Atrium::Showcase.find(params[:atrium_showcase_id])
    @showcase_navigation_data = get_showcase_navigation_data
    logger.debug("Showcase: #{@showcase.inspect}")
    redirect_to atrium_exhibit_path(:edit_browse_page=>true,:id=>@showcase.atrium_exhibit_id, :showcase_number=>@showcase.id, :browse_page_id=>params[:id])
  end

  def featured
    session[:copy_folder_document_ids] = session[:folder_document_ids]
    session[:folder_document_ids] = []
    redirect_to catalog_index_path
  end

  def top_level_browse_page(showcase_id)
    browse_pages = Atrium::BrowsePage.find_by_atrium_showcase_id(showcase_id)

  end
end