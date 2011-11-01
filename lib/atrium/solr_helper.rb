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
  def showcases
    @showcases
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
    puts "Atrium initialize Exhibit"
    if params[:controller] == "atrium_exhibits"
      exhibit_id = params[:id]
    elsif params[:atrium_showcase_id]
      showcase = Atrium::Showcase.find(params[:atrium_showcase_id])
      exhibit = showcase.exhibit if showcase
      exhibit_id = exhibit.id if exhibit
    else
      exhibit_id = params[:exhibit_id]
    end

    unless exhibit_id
      logger.error("Could not initialize exhibit. If controller is 'atrium_exhibits' than :id must be defined.  Otherwise, :exhibit_id must be defined.  Params were: #{params.inspect}")
      return
    end

    #begin
      @atrium_exhibit = Atrium::Exhibit.find(exhibit_id)
      raise "No exhibit was found with id: #{exhibit_id}" if @atrium_exhibit.nil?
      #@showcases = @atrium_exhibit.showcases
      logger.error("Exhibit: #{@atrium_exhibit}")
      @extra_controller_params ||= {}
      filter_query_params = solr_search_params(@atrium_exhibit.filter_query_params) unless @atrium_exhibit.filter_query_params.nil?
      queries = []
      #build_lucene_query will be defined if hydra is present to add hydra rights into query etc, otherwise it will be ignored
      queries << build_lucene_query(params[:q]) if respond_to?(:build_lucene_query)
      queries << filter_query_params[:q] if (filter_query_params && filter_query_params[:q])
      queries << params[:q] if params[:q]
      queries.empty? ? q = params[:q] : q = queries.join(" AND ")
      @extra_controller_params.merge!(:q=>q)
#begin
      if (filter_query_params && filter_query_params[:fq])
        @extra_controller_params.merge!(:fq=>filter_query_params[:fq])
        session_search_params = solr_search_params(params)
        if session_search_params[:fq]
          @extra_controller_params.merge!(:fq=>session_search_params[:fq].concat(filter_query_params[:fq]))
        end
      end
#end
      (@response, @document_list) = get_search_results(params, @extra_controller_params)
      #reset to just filters in exhibit filter
     # @extra_controller_params.merge!(:fq=>filter_query_params[:fq]) if filter_query_params[:fq]
      @browse_response = @response
      @browse_document_list = @document_list
      logger.error("Exhibit: #{@atrium_exhibit}, Showcase: #{@atrium_exhibit.showcases}")
    #rescue Exception=>e
    #  logger.error("Could not initialize exhibit information for id #{exhibit_id}. Reason - #{e.to_s}")
    #end
  end

  # Returns an array of Atrium::Showcase objects with its BrowseLevel objects populated with current display
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
  # @return [Array] An array of Atrium::Showcase objects defind for an exhibit with BrowseLevel objects populated with view data
  # @example Get First Browse Level data
  #   You would access the first level of the first browse set as follows:
  #
  #   top_browse_level = showcases.first.browse_levels.first
  #   #get menu values to display
  #   top_browse_level.values
  #   #get label for the browse category
  #   top_browse_level.label
  #   #check if level has a selected value
  #   top_browse_level.selected?
  #
  #   One should use the above methods to generate data for expand/collapse controls, breadcrumbs, etc.
  def get_showcase_navigation_data
    initialize_exhibit if @atrium_exhibit.nil?
    browse_data = []
    unless @atrium_exhibit.nil? || @atrium_exhibit.showcases.nil?
      @atrium_exhibit.showcases.each do |showcase|
        if showcase.respond_to?(:browse_levels) && !showcase.browse_levels.nil?
          updated_browse_levels = get_browse_level_data(showcase.set_number,showcase.browse_levels,browse_response,extra_controller_params,true)
          showcase.browse_levels.each_index do |index|
            showcase.browse_levels.fetch(index).values = updated_browse_levels.fetch(index).values
            showcase.browse_levels.fetch(index).label = updated_browse_levels.fetch(index).label
            showcase.browse_levels.fetch(index).selected = updated_browse_levels.fetch(index).selected
          end
          showcase.browse_levels.flatten!(1)
          browse_data << showcase
        end
      end
    end
    browse_data
  end

  private

  # This is a private method and should not be called directly.
  # get_showcase_navigation_data calls this method to fill out the browse_level_navigation_data array
  # This method calls itself recursively as it generates the current browse state data.
  # It returns the browse levels array with its browse level objects passed in updated
  # with any values, label, and selected value if one is selected.  It will fill in values
  # for the top browse level, and then will only fill in values for the second browse level
  # if something is selected, and so on for any deeper browse levels.  If no label is defined
  # for a browse level, it will fill in the default label for the browse level facet.
  # @param [String] The browse set number for the current browse set
  # @param [Array] The exhibit browse set's array of BrowseLevel objects
  # @param [SolrResponse] the browse response from solr
  # @param [Hash] the extra controller params that need to be passed to solr if we query for another response if necessary to get child level data
  # @return [Array] An array of update BrowseLevel objects that are enhanced with current navigation data such as selected, values, and label filled in
  #   The relevant attributes of a BrowseLevel are
  #   :solr_facet_name [String] the facet used as the category for that browse level
  #   :label [String] browse level category label
  #   :values [Array] values to display for the browse level
  #   :selected [String] the selected value if one
  def get_browse_level_data(showcase_number,browse_levels, response, extra_controller_params,top_level=false)
    updated_browse_levels = []
    unless browse_levels.nil? || browse_levels.empty?
      browse_level = browse_levels.first
      browse_facet_name = browse_level.solr_facet_name
      browse_level.label = facet_field_labels[browse_facet_name] if (browse_level.label.nil? || browse_level.label.blank?)
      if params.has_key?(:showcase_number) && params[:showcase_number].to_i == showcase_number.to_i
        if params.has_key?(:f) && !params[:f].nil?
          temp = params[:f].dup
          unless top_level && !params[:f][browse_facet_name] && !params[:f][browse_facet_name.to_s]
            browse_levels.each_with_index do |cur_browse_level,index|
              params[:f].delete(cur_browse_level.solr_facet_name)
            end
          else
            params[:f] = {}
          end
          (response_without_f_param, @new_document_list) = get_search_results(params,extra_controller_params)
          params[:f] = temp
        else
          response_without_f_param = response
        end
      elsif params.has_key?(:f) && !params[:f].nil?
        temp = params[:f].dup
        params[:f] = {}
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
                updated_browse_levels << get_browse_level_data(showcase_number,browse_levels.slice(1,browse_levels.length-1), response, extra_controller_params)
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

  def get_atrium_browse_page(showcase_id, facet_hash={})
    atrium_browse_page= Atrium::BrowsePage.with_selected_facets(showcase_id,facet_hash)
    logger.error("Get browse page: #{atrium_browse_page.inspect}")
    return atrium_browse_page
  end
end
