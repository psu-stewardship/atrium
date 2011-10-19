class AtriumShowcasesController < ApplicationController

  include Blacklight::SolrHelper
  include Atrium::ExhibitsHelper
  include Atrium::SolrHelper
  include CatalogHelper
  include BlacklightHelper

  before_filter :initialize_exhibit, :except=>[:index, :new, :create]

  def edit
    @showcase = Atrium::Showcase.find(params[:id])
  end

  def update
    @showcase = Atrium::Showcase.find(params[:id])
    if @showcase.update_attributes(params[:atrium_browse_set])
      #refresh_browse_level_label(@atrium_exhibit)
      flash[:notice] = 'Browse set was successfully updated.'        
    end
    redirect_to :controller=>"atrium_exhibits", :action => "edit", :id=>@showcase.atrium_exhibit_id
  end
end
