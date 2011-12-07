class AtriumCustomizationController < ApplicationController
  def start
    session[:edit_showcase] = true

    respond_to do |format|
      format.html  { redirect_to redirect_target}
      format.json  { render :json => session[:edit_showcase] }
    end
  end

  def stop
    session[:edit_showcase] = nil

    respond_to do |format|
      format.html  { redirect_to redirect_target}
      format.json  { render :json => session[:edit_showcase] }
    end
  end

  private

  def redirect_target
    if params.has_key?(:type) && params.has_key?(:id)
      build_path_from_params
    else
      request.referrer
    end
  end

  def build_path_from_params
    case params[:type]
    when 'collection'
      atrium_collection_path(params[:id])
    when 'exhibit'
      atrium_exhibits_path(params[:id])
    else
      request.referrer
    end
  end

end
