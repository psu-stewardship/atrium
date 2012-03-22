# This module is a controller level mixin that helps render the appropriate layout for the given context
module Atrium::LayoutHelper
  def current_layout
    @atrium_collection ? @atrium_collection.theme_path : 'atrium'
  end

  def collection_theme_if_present
    unless params[:collection_id].blank?
      @atrium_collection ||= Atrium::Collection.find(params[:collection_id])
    end
    current_layout
  end
end
