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
  def browse_sets
    @browse_sets
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
      @browse_sets = @atrium_exhibit.browse_sets
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
  
  # Returns an array of Atrium::BrowseSet objects with its BrowseLevel objects populated with current display
  # data.  It is expected that it will be used for generating current navigation controls when browsing an exhibit.
  # All possible browse levels will be present but values will only be filled in for levels that should be
  # in view.  It will fill in values for the top browse level, and then will only fill in values for the second browse level
  # if something is selected, and so on for any deeper browse levels.  If no label is defined
  # for a browse level, it will fill in the default label for the browse level facet.
  # If nothing is selected in the first level, there will be no second element.  This pattern
  # continues as it maintains the state for a user drilling into the content by expanding and collapses
  # browse category values at each browse level.  This method calls get_browse_level_data
  # to actually retrieve the array of data after it makes sure a response for browse information
  # has come back from Blacklight Solr
  # @return [Array] An array of Atrium::BrowseSet objects defind for an exhibit with BrowseLevel objects populated with view data
  # @example Get First Browse Level data
  #   You would access the first level of the first browse set as follows:
  #
  #   top_browse_level = browse_sets.first.browse_levels.first
  #   #get menu values to display
  #   top_browse_level.values
  #   #get label for the browse category
  #   top_browse_level.label
  #   #check if level has a selected value
  #   top_browse_level.selected?
  #   
  #   One should use the above methods to generate data for expand/collapse controls, breadcrumbs, etc.
  def get_browse_level_navigation_data
    initialize_exhibit if atrium_exhibit.nil?
    browse_data = []
    unless atrium_exhibit.nil? || atrium_exhibit.browse_sets.nil?
      atrium_exhibit.browse_sets.each do |browse_set|
        if browse_set.respond_to?(:browse_levels) && !browse_set.browse_levels.nil?
          updated_browse_levels = get_browse_level_data(browse_set.browse_levels,browse_response,extra_controller_params)
          browse_set.browse_levels.each_index do |index|
            browse_set.browse_levels.fetch(index).values = updated_browse_levels.fetch(index).values
            browse_set.browse_levels.fetch(index).label = updated_browse_levels.fetch(index).label
            browse_set.browse_levels.fetch(index).selected = updated_browse_levels.fetch(index).selected
          end
          browse_set.browse_levels.flatten!(1)
          browse_data << browse_set
        end
      end
    end
    browse_data
  end
  
  private
  
  # This is a private method and should not be called directly.
  # get_browse_level_navigation_data calls this method to fill out the browse_level_navigation_data array
  # This method calls itself recursively as it generates the current browse state data.
  # It returns the browse levels array with its browse level objects passed in updated
  # with any values, label, and selected value if one is selected.  It will fill in values
  # for the top browse level, and then will only fill in values for the second browse level
  # if something is selected, and so on for any deeper browse levels.  If no label is defined
  # for a browse level, it will fill in the default label for the browse level facet.
  # @param [Array] The exhibit browse set's array of BrowseLevel objects
  # @param [SolrResponse] the browse response from solr
  # @param [Hash] the extra controller params that need to be passed to solr if we query for another response if necessary to get child level data
  # @return [Array] An array of update BrowseLevel objects that are enhanced with current navigation data such as selected, values, and label filled in
  #   The relevant attributes of a BrowseLevel are
  #   :solr_facet_name [String] the facet used as the category for that browse level
  #   :label [String] browse level category label
  #   :values [Array] values to display for the browse level
  #   :selected [String] the selected value if one
  def get_browse_level_data(browse_levels, response, extra_controller_params)
    updated_browse_levels = []
    unless browse_levels.nil? || browse_levels.empty?
      browse_level = browse_levels.first
      browse_facet_name = browse_level.solr_facet_name
      browse_level.label = facet_field_labels[browse_facet_name] if (browse_level.label.nil? || browse_level.label.blank?)
      
      if params.has_key?(:f) && !params[:f].nil? && params[:f][browse_facet_name]
        temp = params[:f].dup
        browse_levels.each do |cur_browse_level|
          params[:f].delete(cur_browse_level.solr_facet_name)
        end
        (response_without_f_param, @new_document_list) = get_search_results(params,extra_controller_params)
        params[:f] = temp
      else
        response_without_f_param = response
      end
      display_facet = response_without_f_param.facets.detect {|f| f.name == browse_facet_name}
      display_facet_with_f = response.facets.detect {|f| f.name == browse_facet_name}
      unless display_facet.nil?
        #always add whether there should be values set or not
        updated_browse_levels << browse_level
        level_has_selected = false
        if display_facet.items.any?
          display_facet.items.each do |item|
            if facet_in_params?(display_facet.name, item.value )
              level_has_selected = true
              updated_browse_levels.first.selected = item.value
              if browse_levels.length > 1
                updated_browse_levels << get_browse_level_data(browse_levels.slice(1,browse_levels.length-1), response, extra_controller_params)
                #make sure to flatten any nested arrays from recursive calls
                updated_browse_levels.flatten!(1)
              end
            end
            updated_browse_levels.first.values << item.value
          end
        end
        #check if facet_in_params and if not just add rest of levels so all are represented since nothing below will be selected
        unless level_has_selected
          updated_browse_levels << browse_levels.slice(1,browse_levels.length-1)
          updated_browse_levels.flatten!(1)
        end
      end
    end
    updated_browse_levels
  end
end
