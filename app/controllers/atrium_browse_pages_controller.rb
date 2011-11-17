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
    #@atrium_browse_page = Atrium::BrowsePage.new
    @parent=parent_object
    @atrium_browse_page= Atrium::BrowsePage.with_selected_facets(@parent.id, @parent.class.name, params[:facet_selection]).first

        #Atrium::BrowsePage.with_selected_facets(params[:atrium_showcase_id]).first

    logger.debug("in new: #{@atrium_browse_page.inspect}")

    unless  @atrium_browse_page
      logger.debug("in create params: #{params.inspect}")
      @atrium_browse_page = @parent.browse_pages.build({:browse_pages_id=>@parent.id, :browse_pages_type=>@parent.class.name})
      @atrium_browse_page.save!
      if(params[:facet_selection])
        params[:facet_selection].collect {|key,value|
          facet_selection = @atrium_browse_page.facet_selections.create({:solr_facet_name=>key,:value=>value.first})
          logger.debug("to browse page adding facet selection: #{facet_selection.inspect}")
        }
        @atrium_browse_page.save!
      end
      #@atrium_browse_page.browse_page_items ||= Hash.new
      logger.info("atrium_browse_page = #{@atrium_browse_page.inspect}")
      #@atrium_browse_page.save
    end
    redirect_to :action => "configure_browse_page" , :id=>@atrium_browse_page.id, :f=>params[:facet_selection]

  end

  def create
    logger.debug("in create params: #{params.inspect}")
      @atrium_browse_page = Atrium::BrowsePage.new(params[:atrium_showcase_id])
      @atrium_browse_page.browse_page_items ||= Hash.new
      logger.info("atrium_browse_page = #{@atrium_browse_page.inspect}")
      @atrium_browse_page.save
    #@atrium_browse_page = Atrium::BrowsePage.new(params[:atrium_browse_page])
    #@atrium_browse_page.browse_page_items ||= Hash.new
    logger.info("atrium_browse_page = #{@atrium_browse_page.inspect}")
    redirect_to :action => "configure_browse_page" , :id=>@atrium_browse_page.id, :atrium_showcase_id=>@atrium_browse_page.atrium_showcase_id
  end

  def edit
    @atrium_browse_page = Atrium::BrowsePage.find(params[:id])

    if @atrium_browse_page.browse_pages_type=="atrium_showcase"
      @showcase= Atrium::Showcase.find_by_id(@atrium_browse_page.browse_pages_id)
      redirect_to atrium_exhibit_path(:edit_browse_page=>true,:id=>@showcase.atrium_exhibit_id, :showcase_number=>@showcase.id, :browse_page_id=>params[:id], :f=>params[:f])
    else
      @atrium_exhibit= Atrium::Exhibit.find_by_id(@atrium_browse_page.browse_pages_id)
      redirect_to atrium_exhibit_path(:edit_browse_page=>true,:id=>@atrium_exhibit.id, :browse_page_id=>params[:id], :f=>params[:f])
    end
    #@showcase = Atrium::Showcase.find(@atrium_browse_page.atrium_showcase_id)

  end

  def update
     @atrium_browse_page = Atrium::BrowsePage.find(params[:browse_page_id])
    if @atrium_browse_page.update_attributes(params[:atrium_browse_page])
      #refresh_browse_level_label(@atrium_exhibit)
      flash[:notice] = 'Browse was successfully updated.'
    end
    redirect_to :action => "edit", :id=>@atrium_browse_page.id, :f=>params[:f]
  end

  def show
  #  @atrium_browse_page = Atrium::BrowsePage.find(params[:id])
  #  selected_document_ids = @atrium_browse_page.browse_page_items["solr_doc_ids"]
  #  logger.debug("Selected Highlight: #{selected_document_ids.inspect}, folders_selected: #{session[:folder_document_ids].inspect}")
  #  @response, @documents = get_solr_response_for_field_values("id",selected_document_ids || [])
  #  render :layout => false, :locals=>{:selected_document_ids=>selected_document_ids}
    @atrium_browse_page = Atrium::BrowsePage.find(params[:browse_page_id])
    @atrium_browse_page.browse_page_items ||= Hash.new
    selected_document_ids = session[:folder_document_ids]
    @atrium_browse_page.browse_page_items[:type]="featured"
    @atrium_browse_page.browse_page_items[:solr_doc_ids]=selected_document_ids.join(',')
    @atrium_browse_page.save
    session[:folder_document_ids] = session[:copy_folder_document_ids]
    logger.debug("@atrium_browse_page: #{@atrium_browse_page.inspect},Selected Highlight: #{selected_document_ids.inspect}, folders_selected: #{session[:folder_document_ids].inspect}")
    @response, @documents = get_solr_response_for_field_values("id",@atrium_browse_page.browse_page_items[:solr_doc_ids].split(',') || [])
    render :layout => false, :locals=>{:selected_document_ids=>selected_document_ids}
    #@showcase = Atrium::Showcase.find(@atrium_browse_page.atrium_showcase_id)
    #redirect_to atrium_exhibit_path(:edit_browse_page=>true,:id=>@showcase.atrium_exhibit_id, :showcase_number=>@showcase.id, :browse_page_id=>params[:id], :f=>params[:f])
  end

  def destroy

  end

  def configure_browse_page
    logger.debug("in configure_browse_page params: #{params.inspect}")
    unless  @atrium_browse_page
      @atrium_browse_page=Atrium::BrowsePage.find(params[:id])
    end

    @showcase_navigation_data = get_showcase_navigation_data
    logger.debug("Showcase: #{@showcase.inspect}")
    if @atrium_browse_page.browse_pages_type=="Atrium::Showcase"
      redirect_to atrium_showcase_path(@atrium_browse_page.browse_pages_id,:edit_browse_page=>true,:atrium_browse_page_type=>"atrium_showcase", :f=>params[:f])
      #redirect_to atrium_exhibit_path(:id=>@showcase.atrium_exhibit_id, :showcase_number=>@showcase.id, :browse_page_id=>params[:id], :f=>params[:f])
    else
      @atrium_exhibit= Atrium::Exhibit.find_by_id(@atrium_browse_page.browse_pages_id)
      redirect_to atrium_exhibit_path(:edit_browse_page=>true,:id=>@atrium_browse_page.browse_pages_id, :browse_page_id=>params[:id], :f=>params[:f])
    end
  end

  def featured
    session[:copy_folder_document_ids] = session[:folder_document_ids]
    session[:folder_document_ids] = []
    @atrium_browse_page = Atrium::BrowsePage.find(params[:id])
    logger.debug("#{@atrium_browse_page.inspect}, #{@atrium_browse_page.browse_page_items[:solr_doc_ids]}")
    session[:folder_document_ids] = @atrium_browse_page.browse_page_items[:solr_doc_ids].split(',') unless @atrium_browse_page.browse_page_items[:solr_doc_ids].nil?
    #make sure to pass in a search_fields parameter so that it shows search results immediately
    redirect_to catalog_index_path(:add_featured=>true,:exhibit_id=>params[:exhibit_id],:search_field=>"all_fields",:f=>params[:f])
  end

  def selected_featured
     @atrium_browse_page = Atrium::BrowsePage.find(params[:id])
    selected_document_ids = session[:folder_document_ids]
    session[:folder_document_ids] = session[:copy_folder_document_ids]
    logger.debug("Selected Highlight: #{selected_document_ids.inspect}, folders_selected: #{session[:folder_document_ids].inspect}")
    @response, @documents = get_solr_response_for_field_values("id",selected_document_ids || [])
    render :layout => false, :locals=>{:selected_document_ids=>selected_document_ids}
  end

  private

  def parent_object
    case
      when params[:atrium_showcase_id] then parent= Atrium::Showcase.find_by_id(params[:atrium_showcase_id])
      when params[:atrium_exhibit_id] then parent = Atrium::Exhibit.find_by_id(params[:atrium_exhibit_id])
    end
    logger.debug("Parent: #{parent.inspect}")
    return parent
  end

  def parent_url(parent)
    case
      when params[:article_id] then article_url(parent)
      when params[:news_id] then news_url(parent)
    end
  end

end
