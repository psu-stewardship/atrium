class Atrium::Search::FacetSelection
  attr_accessor :field_name

  def initialize(*args)
    attrs = args.flatten.first
    @field_name = attrs[:field_name] if attrs.has_key?(:field_name)
  end

  def label
    @label ||= Blacklight.config[:facet][:labels][field_name]
  end

end
