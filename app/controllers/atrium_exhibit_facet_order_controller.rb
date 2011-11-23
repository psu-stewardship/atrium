class AtriumExhibitFacetOrderController < ApplicationController
  def index
    @facet_order = Atrium::Collection.find(params[:id]).facet_order rescue nil

    respond_to do |format|
      format.json  { render :json => @facet_order }
    end
  end

  # NOTE this action is not currently protected from unauthorized use.
  def update
    @collection = Atrium::Exhibit.find(params[:id])
    @collection.facet_order = params[:collection]

    respond_to do |format|
      format.json  { render :json => @collection.facet_order }
    end
  end
end
