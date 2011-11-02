class AtriumExhibitShowcaseOrderController < ApplicationController
  def index
    @exhibit = Atrium::Exhibit.find(params[:id])
    @showcase_order = @exhibit.showcase_order

    respond_to do |format|
      format.json  { render :json => @showcase_order }
    end
  end

  # NOTE this action is not currently protected from unauthorized use.
  def update
    @exhibit = Atrium::Exhibit.find(params[:id])
    @exhibit.showcase_order = params[:collection]

    respond_to do |format|
      format.json  { render :json => @exhibit.showcase_order }
    end
  end
end