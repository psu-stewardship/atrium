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
    respond_to do |format|
      if @browse_set.update_attributes(params[:atrium_browse_set])
        #refresh_browse_level_label(@atrium_exhibit)
        flash[:notice] = 'Browse set was successfully updated.'
        #format.html  { render :controller=>"atrium_exhibits", :action => "edit" }
      else
        #format.html { render :controller=>"atrium_exhibits", :action => "edit" }
      end
    end
  end
end
