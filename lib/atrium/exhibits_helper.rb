# This module provides exhibit helper methods for views in Atrium
#  Will be included in Blacklight Catalog classes (i.e CatalogController) to add Atrium functions
module Atrium::ExhibitsHelper
  def get_exhibits_list
    Atrium::Exhibit.find(:all)
  end

  # Return the link to browse an exhibit
  # @return [String] a formatted url to be used in href's etc.
  def browse_exhibit_link
    atrium_exhibit_path(params[:exhibit_id])
  end

  # Return the link to edit an exhibit
  # @param [String] a css class to use in the link if necessary
  # @return [String] a formatted url to be used in href's etc.
  def edit_exhibit_link(css_class=nil)
    edit_atrium_exhibit_path(params[:id], :class => css_class, :render_search=>"false")
  end

  # Standard display of a facet value in a list. Used in both _facets sidebar
  # partial and catalog/facet expanded list. Will output facet value name as
  # a link to add that to your restrictions, with count in parens. 
  # first arg item is a facet value item from rsolr-ext.
  # options consist of:
  # :suppress_link => true # do not make it a link, used for an already selected value for instance
  def get_browse_facet_path(facet_solr_field, value, options ={})
    p = params.dup
    #p.delete(:f)
    p.delete(:q)
    p.delete(:commit)
    p.delete(:search_field)
    p.delete(:controller)
    p.merge!(:id=>params[:exhibit_id]) if p[:exhibit_id]
    value = [value] unless value.is_a? Array
    p = add_facet_params(facet_solr_field,value,p)
    atrium_exhibit_path(p.merge!({:class=>"browse_facet_select", :action=>"show"}))
  end

  def add_facet_params(field, value, p=nil)
    p = params.dup if p.nil?
    p[:f]||={}
    p[:f][field] ||= []
    p[:f][field].push(value)
    p
  end

  # Standard display of a SELECTED facet value, no link, special span
  # with class, and 'remove' button.
  def get_selected_browse_facet_path(facet_solr_field, value, browse_facets)
    value = [value] unless value.is_a? Array
    remove_params = remove_browse_facet_params(facet_solr_field, value, params, browse_facets)
    remove_params.delete(:render_search) #need to remove if we are in search view and click takes back to browse
    remove_params.merge!(:id=>params[:exhibit_id]) if params[:exhibit_id]
    remove_params.delete(:controller)
    atrium_exhibit_path(remove_params.merge!(:action=>"show"))  
  end

  #Remove current selected facet plus any child facets selected
  def remove_browse_facet_params(solr_facet_field, value, params, browse_facets)
    if browse_facets.include?(solr_facet_field)
      new_params = remove_facet_params(solr_facet_field, value, params)
      #iterate through browseable facets from current on down
      selected_browse_facets = get_selected_browse_facets(browse_facets)
    
      index = browse_facets.index(solr_facet_field)
      browse_facets.slice(index + 1, browse_facets.length - index + 1).each do |f|
        new_params = remove_facet_params(f, selected_browse_facets[f.to_sym], new_params) if selected_browse_facets[f.to_sym]
      end
    else
      new_params = params
    end
    new_params
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

  # Returns the current atrium_exhibit instance variable
  # @return [Atrium::Exhibit]
  def atrium_exhibit
    @atrium_exhibit
  end

  # Returns the current browse_levels instance variable
  # @return [Array] Array of Atrium::BrowseLevel for current Atrium::Exhibit
  def browse_levels
    @browse_levels
  end

  # Returns the current Blacklight solr response for results that should be displayed in current browse navigation scope
  # @return [RSolr::Ext::Response]
  def browse_response
    @browse_response
  end

  # Returns the current document list from Blacklight solr response for results that should be displayed in current browse navigation scope
  # @return [Array] array of SolrDocument returned by search result
  def browse_document_list
    @browse_document_list
  end

  # Returns the current extra controller params used in the query to Solr for Browsing response results
  # @return [Hash]
  def extra_controller_params
    @extra_controller_params
  end

  def initialize_exhibit
    if params[:controller] == "atrium_exhibits"
      exhibit_id = params[:id]
    else
      exhibit_id = params[:exhibit_id]
    end

    unless exhibit_id
      logger.error("Could not initialize exhibit. If controller is 'atrium_exhibits' than :id must be defined.  Otherwise, :exhibit_id must be defined.  Params were: #{params.inspect}")
      return
    end

    begin
      @atrium_exhibit = Atrium::Exhibit.find(exhibit_id)
      raise "No exhibit was found with id: #{exhibit_id}" if @atrium_exhibit.nil?
      @browse_levels = @atrium_exhibit.browse_levels
      @extra_controller_params ||= {}
      exhibit_members_query = @atrium_exhibit.build_members_query
      lucene_query = build_lucene_query(params[:q])
      lucene_query = "#{exhibit_members_query} AND #{lucene_query}" unless exhibit_members_query.empty?
      (@response, @document_list) = get_search_results( @extra_controller_params.merge!(:q=>lucene_query))
      @browse_response = @response
      @browse_document_list = @document_list
    rescue Exception=>e
      logger.error("Could not initialize exhibit information for id #{exhibit_id}. Reason - #{e.to_s}")
    end
  end

  # Returns an array of browse level data that is used for generating current
  # navigation controls when browsing an exhibit.  It will return an array of
  # hashes.  The first hash in the array represents the first level.  If an item
  # in the first level is selected, there will be a second hash element for the second level.
  # If nothing is selected in the first level, there will be no second element.  This pattern
  # continues as it maintains the state for a user drilling into the content by expanding and collapses
  # browse category values at each browse level.  This method calls get_browse_level_data
  # to actually retrieve the array of data after it makes sure a response for browse information
  # has come back from Blacklight Solr
  # @return [Array] An array of hashes (one hash for each level that has a value selected plus the lowest level without something selected.  If nothing is selected there will only be one element in the array for the top level.  The hashes will be in order from top to lowest level
  #
  #   Each hash in the array will have the following elements:
  #   :solr_facet_name [String] the facet used as the category for that browse level
  #   :label [String] browse level category label
  #   :values [Array] values to display for the browse level
  #   :selected [String] the selected value if one
  def get_browse_level_navigation_data
    initialize_exhibit if @atrium_exhibit.nil?
    @atrium_exhibit.nil? ? [] : get_browse_level_data(@browse_levels,@browse_response,@extra_controller_params)
  end

  private

  # This is a private method and should not be called directly.
  # get_browse_level_navigation_data calls this method to fill out the browse_level_navigation_data array
  # This method calls itself recursively as it generates the current browse state data.
  # It returns an array of browse level data that is used for generating current
  # navigation controls when browsing an exhibit.  It will return an array of
  # hashes.  The first hash in the array represents the first level.  If an item
  # in the first level is selected, there will be a second hash element for the second level.
  # If nothing is selected in the first level, there will be no second element.  This pattern
  # continues as it maintains the state for a user drilling into the content by expanding and collapses
  # browse category values at each browse level.
  # @param [Array] The exhibit browse level objects
  # @param [SolrResponse] the browse response from solr
  # @param [Hash] the extra controller params that need to be passed to solr if we query for another response if necessary to get child level data
  # @return [Array] An array of hashes (one hash for each level that has a value selected plus the lowest level without something selected.  If nothing is selected there will only be one element in the array for the top level.  The hashes will be in order from top to lowest level
  #
  #   Each hash in the array will have the following elements:
  #   :solr_facet_name [String] the facet used as the category for that browse level
  #   :label [String] browse level category label
  #   :values [Array] values to display for the browse level
  #   :selected [String] the selected value if one
  def get_browse_level_data(browse_levels, response, extra_controller_params)
    browse_level_data = []
    unless browse_levels.nil? || browse_levels.empty?
      browse_level = browse_levels.first
      browse_facet_name = browse_level.solr_facet_name
      browse_level_hash = {:solr_facet_name => browse_facet_name}
      (browse_level.label.nil? || browse_level.label.blank?) ? browse_level_hash.merge!(:label=>facet_field_labels(browse_facet_name)) : browse_level_hash.merge!(:label=>browse_level.label)
      browse_level_hash.merge!(:values=>[])
      
      if params.has_key?(:f) && !params[:f].nil? && params[:f][browse_facet_name]
        temp = params[:f].dup
        browse_levels.each do |browse_level|
          params[:f].delete(browse_level.solr_facet_name)
        end
        (response_without_f_param, @new_document_list) = get_search_results(extra_controller_params)
        params[:f] = temp
      else
        response_without_f_param = response
      end
      display_facet = response_without_f_param.facets.detect {|f| f.name == browse_facet_name}
      display_facet_with_f = response.facets.detect {|f| f.name == browse_facet_name}
      unless display_facet.nil?
        if display_facet.items.any?
          browse_level_data << browse_level_hash
          display_facet.items.each do |item|
            if facet_in_params?(display_facet.name, item.value )
              browse_level_data.first.merge!({:selected=>item.value})
              if browse_levels.length > 1
                browse_level_data << get_browse_level_data(browse_levels.slice(1,browse_levels.length-1), response, extra_controller_params)
                #make sure to flatten any nested arrays from recursive calls
                browse_level_data.flatten!(1)
              end
            end
            browse_level_data.first[:values] << item.value
          end
        end
      end
    end
    browse_level_data
  end
end
