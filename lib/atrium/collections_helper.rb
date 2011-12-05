module Atrium::CollectionsHelper

  # Standard display of a facet value in a list. Used in both _facets sidebar
  # partial and catalog/facet expanded list. Will output facet value name as
  # a link to add that to your restrictions, with count in parens. 
  # first arg item is a facet value item from rsolr-ext.
  # options consist of:
  # :suppress_link => true # do not make it a link, used for an already selected value for instance
  def get_browse_facet_path(facet_solr_field, value, browse_facets, exhibit_number, opts={})
    logger.debug("Params: #{params.inspect}")
    p = HashWithIndifferentAccess.new
    p.merge!(:f=>params[:f].dup) if params[:f]
    if params[:collection_id]
      #p.merge!(:id=>params[:collection_id])
      p.merge!(:collection_id=>params[:collection_id])
    elsif params[:id] && params[:controller] == "atrium_collections"
      #p.merge!(:id=>params[:id])
      p.merge!(:collection_id=>params[:id])
      #p.merge!(:controller=>params[:controller])
    end
    #if params[:edit_showcase]
    #  p.merge!(:edit_showcase=>true)
    #end
    p.merge!(:id=>exhibit_number)
    p = remove_related_facet_params(facet_solr_field, p, browse_facets, exhibit_number)
    p = add_browse_facet_params(facet_solr_field,value,p)
    #it should only return a path for current facet selection plus parent selected values so if generating for multiple levels, than need to ignore some potentially
    #params[:action] == "edit" ? edit_atrium_collection_path(p.merge!({:class=>"browse_facet_select"})) : atrium_collection_path(p.merge!({:class=>"browse_facet_select"}))
    atrium_exhibit_path(p.merge!({:class=>"browse_facet_select"}))
  end

  def add_browse_facet_params(field, value, p=HashWithIndifferentAccess.new)
    p[:f]||={}
    p[:f][field] ||= []
    p[:f][field].push(value)
    p
  end

  # Standard display of a SELECTED facet value, no link, special span
  # with class, and 'remove' button.
  def get_selected_browse_facet_path(facet_solr_field, value, browse_facets, exhibit_number, opts={})
    logger.debug("Options: #{opts.inspect}")
    value = [value] unless value.is_a? Array
    p = HashWithIndifferentAccess.new
    p.merge!(:f=>params[:f].dup) if params[:f]
    p = remove_related_facet_params(facet_solr_field, p, browse_facets, exhibit_number)
    if params[:collection_id]
      p.merge!(:id=>params[:collection_id])
      p.merge!(:collection_id=>params[:collection_id])
    elsif params[:id] && params[:controller] == "atrium_collections"
      p.merge!(:id=>params[:id])
      p.merge!(:collection_id=>params[:id])
      p.merge!(:controller=>params[:controller])
    end
    #if params[:edit_showcase]
    #  p.merge!(:edit_showcase=>true)
    #end
    p.merge!(:id=>exhibit_number)
   # params[:action] == "edit" ? edit_atrium_collection_path(p) : atrium_collection_path(p)
    atrium_exhibit_path(p)
  end

  #Remove current selected facet plus any child facets selected
  def remove_related_facet_params(solr_facet_field, p, browse_facets, exhibit_number)
    if params[:exhibit_number] && params[:exhibit_number].to_i != exhibit_number.to_i
      p.delete(:f) if p[:f]
    elsif browse_facets.include?(solr_facet_field)
      #iterate through browseable facets from current on down
      index = browse_facets.index(solr_facet_field)
      if p[:f]
        browse_facets.slice(index, browse_facets.length - index).each do |f|
          p[:f].delete(f)
        end
      end
    end
    p
  end

  def get_selected_browse_facets(browse_facets)
    selected = {}
    if params[:f]
      browse_facets.each do |facet|
        selected.merge!({facet.to_sym=>params[:f][facet].first}) if params[:f][facet]
      end
    end
    selected
  end

  def grouped_result_count(response, facet_name=nil, facet_value=nil)
    if facet_name && facet_value
      facet = response.facets.detect {|f| f.name == facet_name}
      facet_item = facet.items.detect {|i| i.value == facet_value} if facet
      count = facet_item ? facet_item.hits : 0
    else
      count = response.docs.total
    end
    pluralize(count, 'document')
  end

  def get_collections_list
    Atrium::Collection.find(:all)
  end

  # Return the link to browse an collection
  # @return [String] a formatted url to be used in href's etc.
  def browse_collection_link
    atrium_collection_path(get_collection_id)
  end

  # Returns the current collection id in the parameters.
  # If the current controller is atrium_collections it expects the collection id to be in params[:id]
  # Otherwise, it expects it to be in params[:collection_id]
  # @return [String] the collection id
  def get_collection_id
    params[:controller] == "atrium_collections" ? params[:id] : params[:collection_id]
  end

  # Return the link to edit an collection
  # @param [String] a css class to use in the link if necessary
  # @return [String] a formatted url to be used in href's etc.
  def edit_collection_link(css_class=nil)
    edit_atrium_collection_path(get_collection_id, :class => css_class, :render_search=>"false")
  end

  def get_customize_page_path
    logger.debug("Params: #{params.inspect}")
    if params[:controller] == "atrium_exhibits"
      exhibit=Atrium::Exhibit.find(params[:id])
      path = new_atrium_exhibit_atrium_showcases_path(exhibit, :facet_selection => params[:f])
    elsif params[:controller] == "atrium_collections"
      collection=Atrium::Collection.find(params[:id])
      path= new_atrium_collection_atrium_showcases_path(collection)
    end
    return path
  end

end
