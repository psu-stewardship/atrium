class AtriumShowcaseFacetOrderController < ApplicationController
  def index
    @facet_order = Atrium::Exhibit.find(params[:id]).facet_order rescue nil

    respond_to do |format|
      format.json  { render :json => @facet_order }
    end
  end

  # NOTE this action is not currently protected from unauthorized use.
  def update
    @showcase = Atrium::Showcase.find(params[:id])
    @showcase.facet_order = params[:collection]

    respond_to do |format|
      format.json  { render :json => @showcase.facet_order }
    end
  end
end
