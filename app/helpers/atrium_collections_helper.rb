module AtriumCollectionsHelper

  include Blacklight::Configurable
  include Blacklight::FacetsHelperBehavior

  def blacklight_config
    CatalogController.blacklight_config
end

end