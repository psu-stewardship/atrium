# This module is a controller level mixin that uses Blacklight::SolrHelper to make calls to solr in an exhibit context
module Atrium::SolrHelper
  
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
  
  # Initialize the exhibit and browse instance variables for a current exhibit scope. To initialize
  # anything it expects params[:id] to the be exhibit id if the current controller is "atrium_exhibits".
  # If it sees params[:exhibit_id] defined that will be used.  If neither are present then nothing will
  # be initialized.
  #   If possibled the following will be initialized: 
  #      @atrium_exhibit [Atrium::Exhibit] The exhibit object
  #      @browse_levels [Array] The array of Atrium::BrowseLevel objects for this exhibit
  #      @browse_response [Solr::Response] The response from solr for current exhibit browse scope (will include any filters/facets applied by browse)
  #      @browse_document_list [Array] An array of SolrDocuments for the current browse scope
  #
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
      queries = []
      #build_lucene_query will be defined if hydra is present to add hydra rights into query etc, otherwise it will be ignored
      queries << build_lucene_query(params[:q]) if respond_to?(:build_lucene_query)
      queries << exhibit_members_query unless exhibit_members_query.empty?
      queries.empty? ? q = params[:q] : q = queries.join(" AND ")
      (@response, @document_list) = get_search_results(params, @extra_controller_params.merge!(:q=>q))
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
      (browse_level.label.nil? || browse_level.label.blank?) ? browse_level_hash.merge!(:label=>facet_field_labels[browse_facet_name]) : browse_level_hash.merge!(:label=>browse_level.label)
      browse_level_hash.merge!(:values=>[])
      
      if params.has_key?(:f) && !params[:f].nil? && params[:f][browse_facet_name]
        temp = params[:f].dup
        browse_levels.each do |browse_level|
          params[:f].delete(browse_level.solr_facet_name)
        end
        (response_without_f_param, @new_document_list) = get_search_results(params,extra_controller_params)
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
