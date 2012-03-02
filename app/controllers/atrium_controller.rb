class AtriumController < ApplicationController

  include CatalogHelper
  include BlacklightHelper
  include Blacklight::SolrHelper
  include AtriumHelper
  include Atrium::SolrHelper
  include Atrium::CollectionsHelper

  layout :custom_layout

  def custom_layout
    @atrium_collection ? @atrium_collection.layout : 'atrium'
  end
end
