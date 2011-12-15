class Atrium::RenderingController < AbstractController::Base
  include AbstractController::Rendering
  include AbstractController::Layouts
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include ActionController::UrlWriter

  # TODO find a way to set the view path to within the gem context
  self.view_paths = '../../app/views/'

  def banner(*args)
    # NOTE the data here is just stubbed out to get the partial to render
    params  ||= {}
    session ||= {}
    session[:edit_showcase] = true
    @atrium_showcase = Atrium::Showcase.first

    render :partial => 'shared/banner'
  end

  def collection_search(*args)
    # NOTE the data here is just stubbed out to get the partial to render
    params ||= {}
    params[:collection_id] = 1

    render :partial => 'shared/collection_search_form'
  end

  def placeholder(*args)
    render :text => 'This feature is not yet implemented.'
  end
end
