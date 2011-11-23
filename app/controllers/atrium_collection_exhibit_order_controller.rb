class AtriumCollectionExhibitOrderController < ApplicationController
  def index
    @exhibit_order = Atrium::Collection.find(params[:id]).exhibit_order rescue nil

    respond_to do |format|
      format.json  { render :json => @exhibit_order }
    end
  end

  # NOTE this action is not currently protected from unauthorized use.
  def update
    @collection = Atrium::Collection.find(params[:id])
    @collection.exhibit_order = params[:collection]

    respond_to do |format|
      format.json  { render :json => @collection.exhibit_order }
    end
  end
end
