class AtriumExhibitsController < ApplicationController

  include CatalogHelper
  include BlacklightHelper
  include Blacklight::SolrHelper
  include AtriumHelper
  include Atrium::SolrHelper
  include Atrium::ExhibitsHelper

  layout 'atrium'

  before_filter :initialize_exhibit, :except=>[:index, :new]
  before_filter :atrium_html_head

  def new
    create
  end

  def create
    logger.debug("in create params: #{params.inspect}")
    @atrium_exhibit = Atrium::Exhibit.new
    @atrium_exhibit.save
    redirect_to :action => "edit", :id=>@atrium_exhibit.id
  end

  def update_embedded_search
    render :partial => "shared/featured_search", :locals=>{:content=>params[:content_type]}
  end

  def show
    #@atrium_exhibit = Atrium::Exhibit.find(params[:id])
    @showcase_navigation_data = get_showcase_navigation_data
    #puts "browse_level_navigation_data: #{@showcase_navigation_data.first.browse_levels.first.values.inspect}"
  end

  def edit
    #@atrium_exhibit = Atrium::Exhibit.find(params[:id])
    @showcase_navigation_data = get_showcase_navigation_data
  end

  def update
    @atrium_exhibit = Atrium::Exhibit.find(params[:id])
    respond_to do |format|
      if @atrium_exhibit.update_attributes(params[:atrium_exhibit])
        refresh_showcase
        flash[:notice] = 'Exhibit was successfully updated.'
        format.html  { render :action => "edit" }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @atrium_exhibit = Atrium::Exhibit.find(params[:id])
    @atrium_exhibit.destroy
  end
=begin
  # Just return nil for exhibit facet limit because we want to display all values for browse links
  def facet_limit_for(facet_field)
    return nil
  end
  helper_method :facet_limit_for

  # Returns complete hash of key=facet_field, value=limit.
  # Used by SolrHelper#solr_search_params to add limits to solr
  # request for all configured facet limits.
  def facet_limit_hash
    Blacklight.config[:facet][:limits]
  end
  helper_method :facet_limit_hash
=end
end

private

def refresh_showcase
  @showcase_navigation_data = get_showcase_navigation_data
end

def refresh_browse_level_label(atrium_exhibit)
  if params[:atrium_exhibit][:browse_levels_attributes]
    params[:atrium_exhibit][:browse_levels_attributes].each_pair do |index,values|
      if values[:solr_facet_name] && !values[:label]
        #reset label if facet changing and other label not supplied
        new_label = facet_field_labels[values[:solr_facet_name]]
        unless new_label.nil? || new_label.empty?
          atrium_exhibit.browse_levels.each_with_index do |browse_level,index|
            if browse_level.solr_facet_name == values[:solr_facet_name]
              atrium_exhibit.browse_levels[index].label = new_label
              atrium_exhibit.save!
              break
            end
          end
        end
      end
    end
  end
end
