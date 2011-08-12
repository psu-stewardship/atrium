require 'net/http'

class AtriumExhibitsController < ApplicationController

  #before_filter :initialize_exhibit, :except=>[:index, :new, :create]
  #before_filter :set_page_style, :only => :show

  include Atrium::ExhibitsHelper
  include BlacklightHelper

  def new
    @atrium_exhibit = Atrium::Exhibit.new

    respond_to do |format|
      format.html 
    end
  end

  def create
    logger.debug("in create params: #{params.inspect}")
    @atrium_exhibit = Atrium::Exhibit.new(params[:atrium_exhibit])

    respond_to do |format|
      if @atrium_exhibit.save
        flash[:notice] = 'Exhibit was successfully created.'
        format.html { redirect_to(@atrium_exhibit) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update_embedded_search
    render :partial => "shared/featured_search", :locals=>{:content=>params[:content_type]}
  end

  def show
    @atrium_exhibit = Atrium::Exhibit.find(params[:id])
  end

  def edit
    @atrium_exhibit = Atrium::Exhibit.find(params[:id])
  end

  def update
    @atrium_exhibit = Atrium::Exhibit.find(params[:id])
    respond_to do |format|
      if @atrium_exhibit.update_attributes(params[:atrium_exhibit])
        refresh_browse_level_label(@atrium_exhibit)
        flash[:notice] = 'Exhibit was successfully updated.'
        format.html  { render :action => "edit" }
      else
        format.html { render :action => "edit" }
      end
    end
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
