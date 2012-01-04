class AtriumDescriptionsController < ApplicationController

  include Blacklight::SolrHelper
  include Atrium::CollectionsHelper
  include Atrium::SolrHelper
  include CatalogHelper
  include BlacklightHelper
  include AtriumHelper

  #before_filter :atrium_html_head
  layout 'atrium'

  before_filter :initialize_collection

  def index
    @atrium_showcase = Atrium::Showcase.find(params[:showcase_id])
    #if session[:edit_showcase]
     # redirect_to stop_atrium_customization_path(@atrium_showcase.for_exhibit? ? {:type => 'exhibit', :id => @exhibit.id} : {:type => 'collection', :id => @atrium_collection.id})
    #end
    render :layout => false
  end

  def new
=begin
    @atrium_showcase = Atrium::Showcase.find(params[:showcase_id])
    @atrium_description = Atrium::Description.new(:atrium_showcase_id=>params[:showcase_id])
    logger.info("@atrium_description = #{@atrium_description.inspect}")
    #@atrium_summary= @atrium_description.build_summary
    @atrium_description.save
    @atrium_description.build_essay
    render :layout => false
=end
    create
  end

  def create
=begin
    @atrium_description = Atrium::Description.new(params[:atrium_description])
    logger.info("@atrium_description = #{@atrium_description.inspect}")
    #logger.info("contents = #{params[:essay_attributes].inspect}, actual content=>#{params[:content]}")
    #@atrium_essays = @atrium_description.build_essay({:atrium_description_id=>@atrium_description.id, :content_type=> "essay",:content=>params[:essay]})
    @atrium_description.build_essay(params[:atrium_description][:essay_attributes])
    @atrium_description.save
    logger.info("@atrium_description = #{@atrium_description.inspect}")
    logger.info("@essay = #{@atrium_description.essay.inspect}")
    redirect_to :action => "show", :id=>@atrium_description.id
=end
    logger.debug("in create params: #{params.inspect}")
    @atrium_description = Atrium::Description.new(:atrium_showcase_id=>params[:showcase_id])
    @atrium_description.save!
    logger.info("@atrium_description = #{@atrium_description.inspect}")
    redirect_to :action => "edit", :id=>@atrium_description.id
  end

  def edit
    @atrium_description = Atrium::Description.find(params[:id])
     logger.debug("Desc: #{@atrium_description.inspect}, essay = #{@atrium_description.essay.inspect},summary = #{@atrium_description.summary.inspect}")
     @atrium_description.build_essay(:content_type=>"essay") unless @atrium_description.essay
     @atrium_description.build_summary(:content_type=>"summary") unless @atrium_description.summary
    #@atrium_desc_content= @atrium_description.contents.first
    #@atrium_desc_essay= @atrium_description.essays.first
    render :layout => false
  end

  def update
    @atrium_description = Atrium::Description.find(params[:id])
    if((params[:atrium_description]) && @atrium_description.update_attributes(params[:atrium_description]))
      logger.info("@atrium_description = #{@atrium_description.inspect}")
      logger.info("essay updated as = #{@atrium_description.essay.inspect}")
      flash[:notice] = 'Description was successfully updated.'
    elsif(params[:essay_attributes] && @atrium_description.essay.update_attributes(params[:essay_attributes]))
      #if @atrium_description.essay.update_attributes(params[:essay_attributes])
        #refresh_browse_level_label(@atrium_collection)
        logger.info("@atrium_description = #{@atrium_description.inspect}")
        logger.info("essay updated as = #{@atrium_description.essay.inspect}")
        flash[:notice] = 'Description was successfully updated.'
      #end
    end
    #elsif (params[:atrium_description])
    #  if(@atrium_description.update_attributes(params[:atrium_description]))
    #   flash[:notice] = 'Description was successfully updated.'
    #  end
    #end
    redirect_to :action => "edit", :id=>@atrium_description.id
  end

  def show
    @atrium_description = Atrium::Description.find(params[:id])
    #render :layout => false
  end

  def destroy
    #Need to delete in AJAX way
    @atrium_description = Atrium::Description.find(params[:id])
    Atrium::Description.destroy(params[:id])
    text = 'Description'+params[:id] +'was deleted successfully.'
    render :text => text
  end

end