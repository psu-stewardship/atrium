class AtriumDescriptionsController < ApplicationController

  include Blacklight::SolrHelper
  include Atrium::CollectionsHelper
  include Atrium::SolrHelper
  include CatalogHelper
  include BlacklightHelper
  include AtriumHelper

  before_filter :atrium_html_head
  layout 'atrium'

  before_filter :initialize_collection

  def index
    @atrium_showcase = Atrium::Showcase.find(params[:atrium_showcase_id])
    render :layout => false
  end

  def new
   @atrium_showcase = Atrium::Showcase.find(params[:atrium_showcase_id])
    render :layout => false
  end

  def create
    @atrium_description = Atrium::Description.new(params[:atrium_description])
    @atrium_description.save!
    logger.info("@atrium_description = #{@atrium_description.inspect}")
    redirect_to :action => "show", :id=>@atrium_description.id
  end

  def edit
    @atrium_description = Atrium::Description.find(params[:id])
    render :layout => false
  end

  def update
     @atrium_description = Atrium::Description.find(params[:id])
    if @atrium_description.update_attributes(params[:atrium_description])
      #refresh_browse_level_label(@atrium_collection)
      flash[:notice] = 'Description was successfully updated.'
    end
    redirect_to :action => "edit", :id=>@atrium_description.id
  end

  def show
    @atrium_description = Atrium::Description.find(params[:id])
    render :layout => false
  end

  def destroy
    #Need to delete in AJAX way
    @atrium_description = Atrium::Description.find(params[:id])
    Atrium::Description.destroy(params[:id])
    text = 'Description'+params[:id] +'was deleted successfully.'
    render :text => text
  end

end