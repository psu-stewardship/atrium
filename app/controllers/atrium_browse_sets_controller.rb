class AtriumBrowseSetsController < ApplicationController

  include Blacklight::SolrHelper
  include Atrium::ExhibitsHelper
  include Atrium::SolrHelper
  include CatalogHelper
  include BlacklightHelper

  before_filter :initialize_exhibit, :except=>[:index, :new, :create]

  def edit
    @browse_set = Atrium::BrowseSet.find(params[:id])
  end

  def update
    @browse_set = Atrium::BrowseSet.find(params[:id])
    if @browse_set.update_attributes(params[:atrium_browse_set])
      #refresh_browse_level_label(@atrium_exhibit)
      flash[:notice] = 'Browse set was successfully updated.'        
    end
    redirect_to :controller=>"atrium_exhibits", :action => "edit", :id=>@browse_set.atrium_exhibit_id
  end
end
