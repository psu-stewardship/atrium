class Atrium::Search::FacetSelection
  attr_accessor :field_name

  def initialize(*args)
    attrs = args.flatten.first
    @field_name = attrs[:field_name] if attrs.has_key?(:field_name)
  end

  def label

    #@label ||= Blacklight.config[:facet][:labels][field_name]
    # DEPRECATED
    logger.debug(Hash[*CatalogController.blacklight_config.facet_fields.map { |key, facet| [key, facet.label] }.flatten])
    @label ||= Hash[*CatalogController.blacklight_config.facet_fields.map { |key, facet| [key, facet.label] }.flatten]
  end

end
