class AtriumController < ApplicationController

  include CatalogHelper
  include BlacklightHelper
  include Blacklight::SolrHelper
  include AtriumHelper
  include Atrium::SolrHelper
  include Atrium::CollectionsHelper

  layout :current_layout

  def current_layout
    @atrium_collection ? @atrium_collection.theme_path : 'atrium'
  end
end
