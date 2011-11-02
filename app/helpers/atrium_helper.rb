module AtriumHelper
  include BlacklightHelper

  def application_name
    'Atrium Application'
  end

  def atrium_html_head
    logger.debug("Into atrium_html_head html head")
    if use_asset_pipeline?
      stylesheet_links  << ["application"]
      javascript_includes << ["application"]
    else
      stylesheet_links << ['colorbox', 'atrium/chosen', 'atrium/atrium', {:media=>'all'}]
      javascript_includes << ['jquery.colorbox', 'atrium/chosen.jquery.min', 'atrium/atrium']
    end
  end

  # An array of strings to be added to HTML HEAD section of view.
  def extra_head_content
    @extra_head_content ||= []
  end


  # Array, where each element is an array of arguments to
  # Rails stylesheet_link_tag helper. See
  # ApplicationHelper#render_head_content for details.
  def stylesheet_links
    @stylesheet_links ||= []
  end

  # Array, where each element is an array of arguments to
  # Rails javascript_include_tag helper. See
  # ApplicationHelper#render_head_content for details.
  def javascript_includes
    @javascript_includes ||= []
  end

  # used in the catalog/_facets partial
  def facet_field_names
    exhibit = Atrium::Exhibit.find(params[:exhibit_id]) if params[:exhibit_id] && !params[:edit_exhibit_filter]
    if exhibit
      exhibit.search_facets.collect {|f| f.name}
    else
      super
    end
  end

end
