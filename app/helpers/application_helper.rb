#require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/lib/mediashelf/active_fedora_helper.rb"
#require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"
require 'cgi'

module ApplicationHelper

  #include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  #include Hydra::AccessControlsEnforcement
  #include HydraHelper
  



  # Standard display of a facet value in a list. Used in both _facets sidebar
  # partial and catalog/facet expanded list. Will output facet value name as
  # a link to add that to your restrictions, with count in parens. 
  # first arg item is a facet value item from rsolr-ext.
  # options consist of:
  # :suppress_link => true # do not make it a link, used for an already selected value for instance
  def render_browse_facet_value(facet_solr_field, item, options ={})
    p = params.dup
    #p.delete(:f)
    p.delete(:q)
    p.delete(:commit)
    p.delete(:search_field)
    p.delete(:controller)
    p.merge!(:id=>params[:exhibit_id]) if p[:exhibit_id]
    p = add_facet_params(facet_solr_field,item.value,p)
    link_to(item.value, atrium_exhibit_path(p.merge!({:class=>"browse_facet_select", :action=>"show"})))
  end

  # Standard display of a SELECTED facet value, no link, special span
  # with class, and 'remove' button.
  def render_selected_browse_facet_value(facet_solr_field, item, browse_facets)
    logger.debug("catalog params: #{params.inspect}")
    logger.debug("render_selected_browse_facet_value: #{facet_solr_field.inspect}, #{item.inspect}, #{browse_facets.inspect}")
    remove_params = remove_browse_facet_params(facet_solr_field, item.value, params, browse_facets)
    remove_params.delete(:render_search) #need to remove if we are in search view and click takes back to browse
    remove_params.merge!(:id=>params[:exhibit_id]) if params[:exhibit_id]
    remove_params.delete(:controller)
    '<span class="selected">' +
      link_to("-", atrium_exhibit_path(remove_params.merge!(:action=>"show")), :class=>"remove") + 
      link_to("#{item.value}", atrium_exhibit_path(remove_params.merge!(:action=>"show")), :class=>"browse_facet") +
    '</span>'
      
  end

  #Remove current selected facet plus any child facets selected
  def remove_browse_facet_params(solr_facet_field, value, params, browse_facets)
    logger.debug("Solr facet field: #{solr_facet_field.inspect}")
    new_params = remove_facet_params(solr_facet_field, value, params)
    #iterate through browseable facets from current on down
    selected_browse_facets = get_selected_browse_facets(browse_facets)
    index = browse_facets.index(solr_facet_field)
    browse_facets.slice(index + 1, browse_facets.length - index + 1).each do |f|
      new_params = remove_facet_params(f, selected_browse_facets[f.to_sym], new_params) if selected_browse_facets[f.to_sym]
    end
    logger.debug("new_params: #{new_params.inspect}")
    new_params
  end

  def edit_and_browse_exhibit_links(exhibit)
    result = ""
    if params[:action] == "edit" || params[:action] == "update"
      result << "<a href=\"#{atrium_exhibit_path(params[:exhibit_id])}\" class=\"browse toggle\">View</a>"
      result << "<span class=\"edit toggle active\">Edit</span>"
    else
      result << "<span class=\"browse toggle active\">View</span>"
      result << "<a href=\"#{edit_atrium_exhibit_path(params[:id], :class => "edit_exhibit", :render_search=>"false")}\" class=\"edit toggle\">Edit</a>"
    end
    return result
  end

  def edit_and_browse_subexhibit_links(subexhibit)
    result = ""
    if params[:action] == "edit"
      browse_params = params.dup
      browse_params.delete(:action)
      browse_params.delete(:controller)
      browse_params.merge!(:viewing_context=>"browse")
      result << "<a href=\"#{atrium_exhibit_path(browse_params.merge!(:id=>params[:exhibit_id]))}\" class=\"browse toggle\">View</a>"
      result << "<span class=\"edit toggle active\">Edit</span>"
    else
      result << "<span class=\"browse toggle active\">View</span>"
      if(subexhibit.nil?)
        result << "<a href=\"#{url_for(:action => "new", :controller => "sub_exhibits", :content_type => "sub_exhibit", :exhibit_id => @document[:id], :selected_facets => params[:f])}\" class=\"edit toggle\">Edit</a>"
      else
        result << "<a href=\"#{edit_catalog_path(subexhibit.id, :class => "facet_selected", :exhibit_id => @document[:id], :f => params[:f], :render_search=>"false")}\" class=\"edit toggle\">Edit</a>"
        #edit_params = params.dup
        #edit_params.delete(:viewing_context)
        #edit_params.delete(:action)
        #edit_params.delete(:controller)
        #result << "<a href=\"#{edit_catalog_path(subexhibit.id, edit_params)}\" class=\"edit toggle\">Edit</a>"
      end

    end
    # result << link_to "Browse", "#", :class=>"browse"
    # result << link_to "Edit", edit_document_path(@document[:id]), :class=>"edit"
    return result
  end

  



  def document_link_to_exhibit_sub_exhibit(label, document, counter)

    sub_exhibit = load_af_instance_from_solr(document)
    if !sub_exhibit.nil? && sub_exhibit.respond_to?(:selected_facets)
      p = params.dup
      #remove any previous f params from search
      p.delete(:f)
      sub_exhibit.selected_facets.each_pair do |facet_solr_field,value|
        p = add_facet_params(facet_solr_field,value,p)
      end
      p.delete(:commit)
      p.delete(:search_field)
      p.delete(:q)
      p.delete(:controller)
      link_to(label, atrium_exhibit_path(p.merge!({:id=>sub_exhibit.subset_of_ids.first, :class=>"facet_select", :action=>"show", :exhibit_id=>sub_exhibit.subset_of_ids.first})))
    else
      link_to_document(document, :label => label.to_sym, :counter => (counter + 1 + @response.params[:start].to_i))
    end
  end



  def link_to_exhibit(opts={})
    # params[:f].dup ||
    query_params =  {}
    opts[:exhibit_id] ? exhibit_id = opts[:exhibit_id] : exhibit_id = params[:exhibit_id]
    opts[:f] ? f = opts[:f] : f = params[:f]
    #if opts[:f]
     # f = opts[:f]
    #end 
    query_params.merge!({:id=>exhibit_id})
    query_params.merge!({:f=>f}) if f && !f.empty? && !params[:render_search].blank?
    link_url = atrium_exhibit_path(query_params)
    opts[:label] = exhibit_id unless opts[:label]
    opts[:style] ? link_to(opts[:label], link_url, :style=>opts[:style]) : link_to(opts[:label], link_url)
  end



  def render_browse_facet_div
    initialize_exhibit if @atrium_exhibit.nil?
    @atrium_exhibit.nil? ? '' : get_browse_facet_div(@browse_facets,@browse_response,@extra_controller_params)
  end

  def get_browse_facet_div(browse_facets, response, extra_controller_params)
    #require 'ruby-debug'
    #debugger
    #true
    logger.debug("Param in browse div: #{params.inspect}")
    return_str = ''
    browse_facet = browse_facets.first
    solr_fname = browse_facet.to_s
    if params.has_key?(:f) && !params[:f].nil? && params[:f][browse_facet]
      temp = params[:f].dup
      logger.debug("Removing F params: #{params.inspect}, Removed F params: #{temp.inspect}")
      browse_facets.each do |facet|
        params[:f].delete(facet.to_s)
      end
      logger.debug("Params after delete: #{params.inspect}")
      (response_without_f_param, @new_document_list) = get_search_results(extra_controller_params)
    else
      response_without_f_param = response
    end
    display_facet = response_without_f_param.facets.detect {|f| f.name == solr_fname}
    display_facet_with_f = response.facets.detect {|f| f.name == solr_fname}
    unless display_facet.nil?
      logger.debug("Found display facet: '#{display_facet}'")
      if display_facet.items.any?
        return_str += '<h3 class="facet-heading">' + facet_field_labels[display_facet.name] + '</h3>'
        return_str += '<ul>'
        display_facet.items.each do |item|
          #logger.debug("Check facet value: #{facet_in_temp?( temp, display_facet.name, item.value )}, temp: #{temp.inspect}")
          return_str += '<li>'
          params[:f]=temp if temp
          if facet_in_params?(display_facet.name, item.value )
            if display_facet_with_f.items.any?
              display_facet_with_f.items.each do |item_with_f|
                return_str += render_selected_browse_facet_value(display_facet_with_f.name, item_with_f, browse_facets)
                if browse_facets.length > 1
                  return_str += get_browse_facet_div(browse_facets.slice(1,browse_facets.length-1), response, extra_controller_params)
                end
              end
            end
          else
            browse_facets.each do |facet|
              params[:f].delete(facet.to_s) if params[:f]
            end
            return_str += render_browse_facet_value(display_facet.name, item)
          end
          return_str += '</li>'
        end
        return_str += '</ul>'
      end
    end
    logger.debug("Temp F params are: #{params.inspect}")
    params[:f]=temp if temp 
    logger.debug("Return str for browse nav is: '#{return_str}'")
    return_str
  end

  # true or false, depending on whether the field and value is in params[:f]
  def facet_in_temp?(temp, field, value)
    temp and temp[field] and temp[field].include?(value)
  end

  def get_featured_available(content, featured_query_to_append)
    q = build_lucene_query(params[:q])
    featured_query = [featured_query_to_append]
    lucene_query = "#{featured_query} AND #{q}" unless featured_query.empty?
    extra_controller_params = {}
    get_search_results(extra_controller_params.merge!(:q=>lucene_query) )    
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

  def browse_facet_selected?(browse_facets)
    browse_facets.each do |facet|
      return true if params[:f] and params[:f][facet]
    end
    return false
  end




   def initialize_exhibit
=begin
    require_fedora
    require_solr
=end
    if params[:controller] == "atrium_exhibits"
      exhibit_id = params[:id]
    else
      exhibit_id = params[:exhibit_id]
    end

    unless exhibit_id
      logger.info("No exhibit was found for id #{exhibit_id}")
      logger.info("Params: #{params.inspect}")
      return
    end

    begin
=begin
      @atrium_exhibit = Exhibit.load_instance_from_solr(exhibit_id)
      #@exhibit = Exhibit.load_instance(exhibit_id)
=end
      @atrium_exhibit = Atrium::Exhibit.find(exhibit_id)
      puts "exhibit: #{@atrium_exhibit.inspect}"

      @browse_facets = @atrium_exhibit.browse_facet_names
      logger.debug("Browse facets are: #{@browse_facets.inspect}")
=begin
      @facet_subsets_map = @exhibit.facet_subsets_map
=end
      @selected_browse_facets = get_selected_browse_facets(@browse_facets) 
      #subset will be nil if the condition fails
=begin
      @subset = @facet_subsets_map[@selected_browse_facets] if @selected_browse_facets.any? && @facet_subsets_map[@selected_browse_facets]
      #call exhibit.discriptions once since querying solr everytime on inbound relationship
=end
      if browse_facet_selected?(@browse_facets)
        @subset.nil? ? @descriptions = [] : @descriptions = @subset.descriptions
        (@subset.blank? || @subset.featured.blank? ) ? featured_count = 0 : featured_count = @subset.featured.count
      else
        #use exhibit descriptions
=begin
        @descriptions = @exhibit.descriptions
        @exhibit.featured.blank? ? featured_count=0  : featured_count=@exhibit.featured.count
        #logger.debug("@exhibit.featured.count: #{featured_count}")
=end
      end
#      logger.debug("Description: #{@descriptions}, Subset:#{@subset.inspect}")

      @extra_controller_params ||= {}
      exhibit_members_query = @atrium_exhibit.build_members_query
      lucene_query = build_lucene_query(params[:q])
      lucene_query = "#{exhibit_members_query} AND #{lucene_query}" unless exhibit_members_query.empty?
=begin
      if !params.has_key?(:page)  &&  featured_count>0
        params.has_key?(:per_page) ? result_count=params[:per_page] : result_count=Blacklight.config[:index][:num_per_page]
        #logger.debug("if featured_count: #{featured_count}, params[per_page]: #{params[:per_page]}, result_count:#{result_count}")
        per_page= result_count.to_i-featured_count.to_i
        @extra_controller_params.merge!(:per_page=>per_page)
      elsif params.has_key?(:page) && params[:page].to_i.eql?(1) &&  featured_count>0

        params.has_key?(:per_page) ? result_count=params[:per_page] : result_count=Blacklight.config[:index][:num_per_page]
        #logger.debug("else if featured_count: #{featured_count}, params[per_page]: #{params[:per_page]}, result_count:#{result_count}")
        per_page= result_count.to_i-featured_count.to_i
        @extra_controller_params.merge!(:per_page=>per_page)
      end
=end
      (@response, @document_list) = get_search_results( @extra_controller_params.merge!(:q=>lucene_query))
      @browse_response = @response
      @browse_document_list = @document_list
      logger.debug("browse.response: #{@browse_response.inspect}")
    rescue Exception=>e
      logger.info("No exhibit was found for id #{exhibit_id}: #{e.to_s}")
    end
  end





  def get_exhibits_list
    Atrium::Exhibit.find(:all)
    #Exhibit.find_by_solr(:all).hits.map{|result| Exhibit.load_instance_from_solr(result["id"])}
  end


  def exhibit_page_entries_info(collection, options = {})
    logger.debug("Total collection: #{options.inspect}")
    start = collection.next_page == 2 ? 1 : collection.previous_page * collection.per_page + 1
    options[:response].blank? ? total_hits = @browse_response.total : total_hits = options[:response].total
    start_num = format_num(start)
    start + collection.per_page - 1>total_hits ? end_num=format_num(total_hits) : end_num = format_num(start + collection.per_page - 1)
    total_num = format_num(total_hits)

    entry_name = options[:entry_name] ||
      (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))

    if collection.total_pages < 2
      case collection.size
      when 0; "No #{entry_name.pluralize} found"
      when 1; "Displaying <b>1</b> #{entry_name}"
      else;   "Displaying <b>all #{total_num}</b> #{entry_name.pluralize}"
      end
    else
      "Displaying #{entry_name.pluralize} <b>#{start_num} - #{end_num}</b> of <b>#{total_num}</b>"
    end
  end


end

