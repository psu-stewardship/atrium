class AtriumShowcasesController < ApplicationController

  include CatalogHelper
  include BlacklightHelper
  include Blacklight::SolrHelper
  include AtriumHelper
  include Atrium::SolrHelper
  include Atrium::ExhibitsHelper

  layout 'atrium'

  before_filter :initialize_exhibit, :except=>[:index, :create]
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
          #refresh_browse_level_label(@atrium_exhibit)

        flash[:notice] = 'Showcase was successfully created.'
        format.html { redirect_to :action => "edit", :id=>@showcase.id }
      end
      format.html { render :action => "new" }
    #end
  end

  def edit
    @showcase = Atrium::Showcase.find(params[:id])
    @showcase_navigation_data = get_showcase_navigation_data
  end

  def update
    @showcase = Atrium::Showcase.find(params[:id])
    if @showcase.update_attributes(params[:atrium_showcase])
      #refresh_browse_level_label(@atrium_exhibit)
      flash[:notice] = 'Showcase was successfully updated.'
    end
    redirect_to :action => "edit", :exhibit_id=>@showcase.atrium_exhibit_id
  end

  def destroy
    @showcase = Atrium::Showcase.find(params[:id])
    Atrium::Showcase.destroy(params[:id])
    flash[:notice] = 'Showcase'+params[:id] +'was deleted successfully.'
    redirect_to :controller=>"atrium_exhibits", :action => "edit", :id=>@showcase.atrium_exhibit_id
  end
end
