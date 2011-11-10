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
      params[:add_featured] ? [] : exhibit.search_facets.collect {|f| f.name}
    else
      super
    end
  end

  # link_to_document(doc, :label=>'VIEW', :counter => 3)
  # Use the catalog_path RESTful route to create a link to the show page for a specific item. 
  # catalog_path accepts a HashWithIndifferentAccess object. The solr query params are stored in the session,
  # so we only need the +counter+ param here. We also need to know if we are viewing to document as part of search results.
  def link_to_document(doc, opts={:label=>Blacklight.config[:index][:show_link].to_sym, :counter => nil, :results_view => true})
    params[:controller] == "exhibits" ? exhibit_id = params[:id] : exhibit_id = params[:exhibit_id]
    if exhibit_id
      label = render_document_index_label doc, opts
      args = {:exhibit_id=>exhibit_id}
      args.merge!(:f=>params[:f]) if params[:f] && (params[:controller] != "catalog" || !params[:render_search].blank?)
      args.merge!(:render_search=>"false") unless params[:controller] == "catalog"
      link_to_with_data(label, catalog_path(doc.id, args), {:method => :put, :class => label.parameterize, :data => opts}).html_safe
    else
      super
    end
  end

  # If exhibit is defined and in an exhibit browse view 
  # then do not set limit on facet values displayed.
  # Otherwise use code lifted from catalog controller in blacklight plugin
  def facet_limit_for(facet_field)
    (params[:exhibit_id] && !params[:render_search].blank?) ? nil : super
  end

  # Overriding so that it will not show facet constraints if selecting
  # featured items because we should not be able to remove facet selections
  # that are setting proper search scope for a browse page
  def render_constraints(localized_params = params)
    if params[:add_featured]
      (render_constraints_query(localized_params)).html_safe
    else
      (render_constraints_query(localized_params) + render_constraints_filters(localized_params)).html_safe
    end
  end

end
