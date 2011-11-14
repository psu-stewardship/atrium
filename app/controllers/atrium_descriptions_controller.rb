class AtriumDescriptionsController < ApplicationController

  include Blacklight::SolrHelper
  include Atrium::ExhibitsHelper
  include Atrium::SolrHelper
  include CatalogHelper
  include BlacklightHelper
  include AtriumHelper

  before_filter :atrium_html_head
  layout 'atrium'

  before_filter :initialize_exhibit

  def new
   @atrium_browse_page = Atrium::BrowsePage.find(params[:atrium_browse_page_id])
    #render :layout => false
  end

  def create
    @atrium_description = Atrium::Description.new(params[:atrium_description])
    @atrium_description.save!
    logger.info("@atrium_description = #{@atrium_description.inspect}")
    redirect_to :action => "show", :id=>@atrium_description.id
  end

  def edit
    @atrium_description = Atrium::Description.find(params[:id])
    #render :layout => false
  end

  def update
     @atrium_description = Atrium::Description.find(params[:id])
    if @atrium_description.update_attributes(params[:atrium_description])
      #refresh_browse_level_label(@atrium_exhibit)
      flash[:notice] = 'Description was successfully updated.'
    end
    redirect_to :action => "edit", :id=>@atrium_description.id
  end

  def show
    @atrium_description = Atrium::Description.find(params[:id])
    render :layout => false
  end

  end