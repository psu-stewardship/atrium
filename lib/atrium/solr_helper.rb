# This module is a controller level mixin that uses Blacklight::SolrHelper to make calls to solr in an collection context
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

  # Returns the current atrium_collection instance variable
  # @return [Atrium::Collection]
  def atrium_collection
    @atrium_collection
  end

  # Returns the current showcase instance variable
  # @return [Atrium::Showcase]
  def showcase
    @showcase
  end

  # Returns the current browse_levels instance variable
  # @return [Array] Array of Atrium::BrowseLevel for current Atrium::Collection
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
  def current_extra_controller_params
    @extra_controller_params
  end

  # Initialize the collection and browse instance variables for a current collection scope. To initialize
  # anything it expects params[:id] to the be collection id if the current controller is "atrium_collections".
  # If it sees params[:collection_id] defined that will be used.  If neither are present then nothing will
  # be initialized.
  #   If possibled the following will be initialized:
  #      @atrium_collection [Atrium::Collection] The collection object
  #      @browse_levels [Array] The array of Atrium::BrowseLevel objects for this collection
  #      @browse_response [Solr::Response] The response from solr for current collection browse scope (will include any filters/facets applied by browse)
  #      @browse_document_list [Array] An array of SolrDocuments for the current browse scope
  #
  def initialize_collection
    if params[:controller] == "atrium_collections"
      collection_id = params[:id]
    elsif params[:controller] =="atrium_showcases"
      @showcase = Atrium::Showcase.find(params[:id])
      collection = @showcase.collection if @showcase
      collection_id = collection.id if collection
    elsif params[:atrium_showcase_id]
      @showcase = Atrium::Showcase.find(params[:atrium_showcase_id])
      collection = @showcase.collection if @showcase
      collection_id = collection.id if collection
    else
      collection_id = params[:collection_id]
    end

    unless collection_id
      logger.error("Could not initialize collection. If controller is 'atrium_collections' than :id must be defined.  Otherwise, :collection_id must be defined.  Params were: #{params.inspect}")
      return
    end

    begin
      @atrium_collection = Atrium::Collection.find(collection_id)
      raise "No collection was found with id: #{collection_id}" if @atrium_collection.nil?
      @showcases = @atrium_collection.showcases
      if params[:showcase_number]
        showcase_index = params[:showcase_number].to_i 
        @showcase = @showcases.fetch(showcase_index-1) if @showcases && showcase_index && showcase_index <= @showcases.size
      elsif params[:showcase_id]
        @showcase = Atrium::Showcase.find(params[:showcase_id])
      end
      logger.debug("Collection: #{@atrium_collection}")
      @extra_controller_params ||= {}
      params[:browse_level_id] ? @browse_level = Atrium::BrowseLevel.find(params[:browse_level_id]): @browse_level = get_current_browse_level(@showcase)  
      @extra_controller_params = prepare_extra_controller_params_for_collection_query(@atrium_collection,@showcase,@browse_level,params,@extra_controller_params)
      (@response, @document_list) = get_search_results(params, @extra_controller_params)
      #reset to just filters in collection filter
      @extra_controller_params = reset_extra_controller_params_after_collection_query(@atrium_collection,@showcase,@browse_level,@extra_controller_params)
      @browse_response = @response
      @browse_document_list = @document_list
      logger.debug("Collection: #{@atrium_collection}, Showcase: #{@atrium_collection.showcases}")
    rescue Exception=>e
      logger.error("Could not initialize collection information for id #{collection_id}. Reason - #{e.to_s}")
    end
  end

  def get_current_filter_query_params(collection,showcase,browse_level)
    filter_query_params = nil
    ex_filter_query_params = solr_search_params(collection.filter_query_params) if collection && !collection.filter_query_params.nil?
    showcase_filter_query_params = solr_search_params(showcase.filter_query_params) if showcase && !showcase.filter_query_params.nil?
    bl_filter_query_params = solr_search_params(browse_level.filter_query_params) if browse_level && !browse_level.filter_query_params.nil?
    queries = []
    queries << ex_filter_query_params[:q] if (ex_filter_query_params && ex_filter_query_params[:q])
    queries << showcase_filter_query_params[:q] if (showcase_filter_query_params && showcase_filter_query_params[:q])
    queries << bl_filter_query_params[:q] if (bl_filter_query_params && bl_filter_query_params[:q])
    fq = []
    fq.concat(ex_filter_query_params[:fq]) if (ex_filter_query_params && ex_filter_query_params[:fq])
    #mixin showcase facet filters
    if showcase_filter_query_params && showcase_filter_query_params[:fq]
      showcase_filter_query_params[:fq].each do |fq_param| 
        fq << fq_param unless fq.include?(fq_param)
      end
    end
    #mixin browse level facet filters
    if bl_filter_query_params && bl_filter_query_params[:fq]
      bl_filter_query_params[:fq].each do |fq_param| 
        fq << fq_param unless fq.include?(fq_param)
      end
    end
    unless fq.empty? && queries.empty?
      filter_query_params = {}
      filter_query_params.merge!(:fq=>fq) unless fq.empty?
      filter_query_params.merge!(:q=>queries.join(" AND ")) unless queries.empty?
    end
    filter_query_params
  end

  # This method will get extra controller params that are necessary to apply an
  # collection scope filter.  If there are facets selected in the collection filter and
  # a menu item is selected it will combine the facet selection from params into
  # extra controller params to ensure that both are in the query correctly.

  def prepare_extra_controller_params_for_collection_query(collection,showcase,browse_level,params, extra_controller_params)
    extra_controller_params ||= {}
    filter_query_params = get_current_filter_query_params(collection,showcase,browse_level)
    queries = []
    #build_lucene_query will be defined if hydra is present to add hydra rights into query etc, otherwise it will be ignored
    queries << build_lucene_query(params[:q]) if respond_to?(:build_lucene_query)
    queries << filter_query_params[:q] if (filter_query_params && filter_query_params[:q])
    queries << params[:q] if params[:q]
    queries.empty? ? q = params[:q] : q = queries.join(" AND ")
    extra_controller_params.merge!(:q=>q) unless q.nil?
    extra_controller_params.merge!(:fq=>filter_query_params[:fq]) if filter_query_params && filter_query_params[:fq]
    #merge in user params before doing query to correctly handle facets in both extra controller params and params
    if (extra_controller_params && extra_controller_params[:fq])
      session_search_params = solr_search_params(params)
      if session_search_params[:fq]
        extra_controller_params[:fq].each do |extra_param|
          #only add if it is not already in params
          session_search_params[:fq] << extra_param unless session_search_params[:fq].include?(extra_param)
        end
        extra_controller_params.merge!(:fq=>session_search_params[:fq])
      end
    end
    extra_controller_params
  end

  def reset_extra_controller_params_after_collection_query(collection,showcase,browse_level,extra_controller_params)
    extra_controller_params ||= {}
    filter_query_params = get_current_filter_query_params(collection,showcase,browse_level)
    extra_controller_params.merge!(:fq=>filter_query_params[:fq]) if filter_query_params && filter_query_params[:fq]
    extra_controller_params
  end

  # Returns an array of Atrium::Showcase objects with its BrowseLevel objects populated with current display
  # data.  It is expected that it will be used for generating current navigation controls when browsing an collection.
  # All possible browse levels will be present but values will only be filled in for levels that should be
  # in view.  It will fill in values for the top browse level, and then will only fill in values for the second browse level
  # if something is selected, and so on for any deeper browse levels.  If no label is defined
  # for a browse level, it will fill in the default label for the browse level facet.
  # If nothing is selected in the first level, there will be no second element.  This pattern
  # continues as it maintains the state for a user drilling into the content by expanding and collapses
  # browse category values at each browse level.  This method calls get_browse_level_data
  # to actually retrieve the array of data after it makes sure a response for browse information
  # has come back from Blacklight Solr
  # @return [Array] An array of Atrium::Showcase objects defind for an collection with BrowseLevel objects populated with view data
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
    initialize_collection if atrium_collection.nil?
    browse_data = []
    unless atrium_collection.nil? || atrium_collection.showcases.nil?
      atrium_collection.showcases.each do |showcase|
        if showcase.respond_to?(:browse_levels) && !showcase.browse_levels.nil?
          updated_browse_levels = get_browse_level_data(atrium_collection,showcase,showcase.browse_levels,browse_response,current_extra_controller_params,true)
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
  # @param [Atrium::Collection] The current collection
  # @param [Atrium::Showcase] the current showcase
  # @params [Array] The current browse levels (will reduce as this method recurses)
  # @param [SolrResponse] the browse response from solr
  # @param [Hash] the extra controller params that need to be passed to solr if we query for another response if necessary to get child level data
  # @param [Boolean] true if the top level of the showcase
  # @return [Array] An array of update BrowseLevel objects that are enhanced with current navigation data such as selected, values, and label filled in
  #   The relevant attributes of a BrowseLevel are
  #   :solr_facet_name [String] the facet used as the category for that browse level
  #   :label [String] browse level category label
  #   :values [Array] values to display for the browse level
  #   :selected [String] the selected value if one
  def get_browse_level_data(collection, showcase, browse_levels, response, extra_controller_params={},top_level=false)
    showcase_number = showcase.set_number
    updated_browse_levels = []
    unless browse_levels.nil? || browse_levels.empty?
      browse_level = browse_levels.first
      browse_facet_name = browse_level.solr_facet_name
      browse_level.label = facet_field_labels[browse_facet_name] if (browse_level.label.nil? || browse_level.label.blank?)
      #always add whether there should be values set or not
      updated_browse_levels << browse_level
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
          extra_controller_params = prepare_extra_controller_params_for_collection_query(collection,showcase,browse_level,params,extra_controller_params)
          puts "extra controller params before: #{extra_controller_params.inspect}"
          (response_without_f_param, @new_document_list) = get_search_results(params,extra_controller_params)
          extra_controller_params = reset_extra_controller_params_after_collection_query(collection,showcase,browse_level,extra_controller_params)
          puts "extra controller params after: #{extra_controller_params.inspect}"
          params[:f] = temp
        else
          response_without_f_param = response
        end
      elsif params.has_key?(:f) && !params[:f].nil?
        temp = params[:f].dup
        params[:f] = {}
        extra_controller_params = prepare_extra_controller_params_for_collection_query(collection,showcase,browse_level,params,extra_controller_params)
        (response_without_f_param, @new_document_list) = get_search_results(params,extra_controller_params)
        extra_controller_params = reset_extra_controller_params_after_collection_query(collection,showcase,browse_level,extra_controller_params)
        params[:f] = temp
      else
        extra_controller_params = prepare_extra_controller_params_for_collection_query(collection,showcase,browse_level,params,extra_controller_params)
        (response_without_f_param, @new_document_list) = get_search_results(params,extra_controller_params)
        extra_controller_params = reset_extra_controller_params_after_collection_query(collection,showcase,browse_level,extra_controller_params)
      end
      display_facet = response_without_f_param.facets.detect {|f| f.name == browse_facet_name}
      display_facet_with_f = response.facets.detect {|f| f.name == browse_facet_name}
      unless display_facet.nil?
        level_has_selected = false
        if display_facet.items.any?
          display_facet.items.each do |item|
            if facet_in_params?(display_facet.name, item.value )
              level_has_selected = true
              updated_browse_levels.first.selected = item.value
              if browse_levels.length > 1
                updated_browse_levels << get_browse_level_data(collection,showcase,browse_levels.slice(1,browse_levels.length-1), response, extra_controller_params)
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

  # Checks if a browse level has been navigated to for a showcase
  # @param [Atrium::Showcase] The current showcase in view
  # @return [Atrium::BrowseLevel] It will return a browse level that is selected, otherwise it will return nil
  def get_current_browse_level(showcase)
    cur_browse_level = nil
    if showcase
      #keep recursing until lowest level that has a facet selected is found
      showcase.browse_levels.each do |browse_level|
        cur_browse_level = browse_level if browse_level.solr_facet_name && facet_selected?(browse_level.solr_facet_name) 
      end
    end
    cur_browse_level
  end

  def facet_selected?(facet_name)
    params[:f].include?(facet_name) if params[:f]
  end
end
