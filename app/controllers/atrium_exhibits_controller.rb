class AtriumExhibitsController < AtriumController

  before_filter :initialize_collection, :except=>[:index, :create]
  before_filter :atrium_html_head

  def new
    logger.debug("in create params: #{params.inspect}")
    @exhibit = Atrium::Exhibit.new
    respond_to do |format|
      format.html
    end
  end

  def create
    logger.debug("in create params: #{params.inspect}")
    @exhibit = Atrium::Exhibit.new(params[:atrium_exhibit])

    @exhibit.save
    logger.debug("in create params: #{@exhibit.inspect}")
    #respond_to do |format|
    if @exhibit.save
      @exhibit.update_attributes(params[:atrium_exhibit])

      flash[:notice] = 'Exhibit was successfully created.'
      format.html { redirect_to :action => "edit", :id=>@exhibit.id }
    end
    format.html { render :action => "new" }
    #end
  end

  def edit
    @exhibit = Atrium::Exhibit.find(params[:id])
    @atrium_collection = @exhibit.collection
    @exhibit_navigation_data = get_exhibit_navigation_data
  end

  def update
    @exhibit = Atrium::Exhibit.find(params[:id])
    if @exhibit.update_attributes(params[:atrium_exhibit])
      #refresh_browse_level_label(@atrium_collection)
      flash[:notice] = 'Exhibit was successfully updated.'
    end
    redirect_to :action => "edit"
  end

  def show
    @exhibit= Atrium::Exhibit.find(params[:id])
    @exhibit_navigation_data = get_exhibit_navigation_data

    if @exhibit && @exhibit.filter_query_params && @exhibit.filter_query_params[:solr_doc_ids]
      logger.debug("Items in Exhibit: #{@exhibit.filter_query_params[:solr_doc_ids]}")
      items_document_ids = @exhibit.filter_query_params[:solr_doc_ids].split(',')
      logger.debug("Exhibit items: #{items_document_ids.inspect}")
      @collection_items_response, @collection_items_documents = get_solr_response_for_field_values("id",items_document_ids || [])
    end

    logger.debug("Browse page: #{@exhibit.showcases}")
    @atrium_showcase=Atrium::Showcase.with_selected_facets(@exhibit.id, @exhibit.class.name, params[:f]).first
    if @atrium_showcase && !@atrium_showcase.showcase_items[:solr_doc_ids].nil?
      logger.debug("#{@atrium_showcase.inspect}, #{@atrium_showcase.showcase_items[:solr_doc_ids]}")
      selected_document_ids = @atrium_showcase.showcase_items[:solr_doc_ids].split(',')
      logger.debug("Collection Selected Highlight: #{selected_document_ids.inspect}")
      @response, @documents = get_solr_response_for_field_values("id",selected_document_ids || [])
    end
  end

  def set_exhibit_scope
    logger.error("into scoping")
    session[:copy_folder_document_ids] = session[:folder_document_ids]
    session[:folder_document_ids] = []
    @exhibit = Atrium::Exhibit.find(params[:id])
    logger.debug("#{@exhibit.inspect}, #{@exhibit.filter_query_params[:solr_doc_ids] if @exhibit.filter_query_params}")
    session[:folder_document_ids] = @exhibit.filter_query_params[:solr_doc_ids].split(',') if @exhibit.filter_query_params && @exhibit.filter_query_params[:solr_doc_ids]
    p = params.dup
    p.delete :action
    p.delete :id
    p.delete :controller
    #make sure to pass in a search_fields parameter so that it shows search results immediately
    redirect_to catalog_index_path(p)
  end

  def unset_exhibit_scope
     @exhibit = Atrium::Exhibit.find(params[:id])
     @exhibit.update_attributes(:filter_query_params=>nil)
     flash[:notice] = 'Exhibit scope removed successfully'
     render :action => "edit"
  end

  def destroy
    @exhibit = Atrium::Exhibit.find(params[:id])
    Atrium::Exhibit.destroy(params[:id])
    flash[:notice] = 'Exhibit'+params[:id] +'was deleted successfully.'
    redirect_to :controller=>"atrium_collections", :action => "edit", :id=>@exhibit.atrium_collection_id
  end

  def blacklight_config
    CatalogController.blacklight_config
  end
end
