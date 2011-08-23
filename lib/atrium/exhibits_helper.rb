module Atrium::ExhibitsHelper

  # Standard display of a facet value in a list. Used in both _facets sidebar
  # partial and catalog/facet expanded list. Will output facet value name as
  # a link to add that to your restrictions, with count in parens. 
  # first arg item is a facet value item from rsolr-ext.
  # options consist of:
  # :suppress_link => true # do not make it a link, used for an already selected value for instance
  def get_browse_facet_path(facet_solr_field, value, browse_facets)
    p = HashWithIndifferentAccess.new
    p.merge!(:f=>params[:f].dup) if params[:f]
    p.merge!(:id=>params[:exhibit_id]) if params[:exhibit_id]
    p = remove_related_facet_params(facet_solr_field, p, browse_facets)
    p = add_browse_facet_params(facet_solr_field,value,p)
    #it should only return a path for current facet selection plus parent selected values so if generating for multiple levels, than need to ignore some potentially
    atrium_exhibit_path(p.merge!({:class=>"browse_facet_select", :action=>"show"}))
  end

  def add_browse_facet_params(field, value, p=HashWithIndifferentAccess.new)
    p[:f]||={}
    p[:f][field] ||= []
    p[:f][field].push(value)
    p
  end

  # Standard display of a SELECTED facet value, no link, special span
  # with class, and 'remove' button.
  def get_selected_browse_facet_path(facet_solr_field, value, browse_facets)
    value = [value] unless value.is_a? Array
    p = HashWithIndifferentAccess.new
    p.merge!(:f=>params[:f].dup) if params[:f]
    p = remove_related_facet_params(facet_solr_field, p, browse_facets)
    p.merge!(:id=>params[:exhibit_id]) if params[:exhibit_id]
    atrium_exhibit_path(p.merge!(:action=>"show"))  
  end

  #Remove current selected facet plus any child facets selected
  def remove_related_facet_params(solr_facet_field, p, browse_facets)
    if browse_facets.include?(solr_facet_field)
      #iterate through browseable facets from current on down
      selected_browse_facets = get_selected_browse_facets(browse_facets)
    
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

  def get_exhibits_list
    Atrium::Exhibit.find(:all)
  end

  # Return the link to browse an exhibit
  # @return [String] a formatted url to be used in href's etc.
  def browse_exhibit_link
    atrium_exhibit_path(get_exhibit_id)
  end

  # Returns the current exhibit id in the parameters.
  # If the current controller is atrium_exhibits it expects the exhibit id to be in params[:id]
  # Otherwise, it expects it to be in params[:exhibit_id]
  # @return [String] the exhibit id
  def get_exhibit_id
    params[:controller] == "atrium_exhibits" ? params[:id] : params[:exhibit_id]
  end

  # Return the link to edit an exhibit
  # @param [String] a css class to use in the link if necessary
  # @return [String] a formatted url to be used in href's etc.
  def edit_exhibit_link(css_class=nil)
    edit_atrium_exhibit_path(get_exhibit_id, :class => css_class, :render_search=>"false")
  end

end
