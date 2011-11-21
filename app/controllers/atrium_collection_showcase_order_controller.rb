class AtriumCollectionShowcaseOrderController < ApplicationController
  def index
    @showcase_order = Atrium::Collection.find(params[:id]).showcase_order rescue nil

    respond_to do |format|
      format.json  { render :json => @showcase_order }
    end
  end

  # NOTE this action is not currently protected from unauthorized use.
  def update
    @collection = Atrium::Collection.find(params[:id])
    @collection.showcase_order = params[:collection]

    respond_to do |format|
      format.json  { render :json => @collection.showcase_order }
    end
  end
end
