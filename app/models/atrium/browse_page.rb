class Atrium::BrowsePage < ActiveRecord::Base
  has_many :featured_items, :class_name=>'Atrium::BrowsePage::Item::Featured', :foreign_key=>"atrium_browse_page_id"
  has_many :related_items, :class_name=>'Atrium::BrowsePage::Item::Related', :foreign_key=>"atrium_browse_page_id"
  has_many :descriptions, :class_name=>'Atrium::Description', :foreign_key=>"atrium_browse_page_id" , :dependent => :destroy

  #belongs_to :showcase, :class_name=>'Atrium::Showcase', :foreign_key=>"atrium_showcase_id"
  belongs_to :browse_details, :polymorphic => true
  has_many :facet_selections, :class_name=>'Atrium::BrowsePage::FacetSelection', :foreign_key=>"atrium_browse_page_id"

  #validates_presence_of :atrium_showcase_id

  serialize :browse_page_items, Hash

  accepts_nested_attributes_for :featured_items, :allow_destroy=>true
  accepts_nested_attributes_for :related_items, :allow_destroy=>true
  accepts_nested_attributes_for :descriptions, :allow_destroy=>true
  accepts_nested_attributes_for :facet_selections

  set_table_name :atrium_browse_pages

  def initialize(opts={})
    super
    #facet
  end

  def browse_page_items
    read_attribute(:browse_page_items) || write_attribute(:browse_page_items, {})
  end


  def type
    browse_page_items[:type] unless browse_page_items.blank?
  end


  def solr_doc_ids
    browse_page_items[:solr_doc_ids]  unless browse_page_items.blank?
  end
   #this method will select browse_page objects that have exactly the selected facets passed in (but no more or no less) and is tied to the given showcase id
  #it expects two parameters:
  # @param[String] the showcase id
  # @param[Hash] hash of key value pairs of selected facets
  # @return Array of browse_page objects found
  scope :with_selected_facets, lambda {|*args|
    parent_id, parent_type, selected_facets = args.flatten(1)
    logger.debug("getting browse page for showcase: #{parent_id.inspect}, type:#{parent_type} and facets: #{selected_facets.inspect}")

    selected_facets ? facet_conditions = selected_facets.collect {|key,value| "(#{Atrium::BrowsePage::FacetSelection.quoted_table_name}.`solr_facet_name` = '#{key}' and #{Atrium::BrowsePage::FacetSelection.quoted_table_name}.`value` = '#{(value.is_a?(String) ? value : value.flatten)}')"} : facet_conditions = {}
    conditions = "#{quoted_table_name}.`browse_pages_id` = #{parent_id} AND #{quoted_table_name}.`browse_pages_type` = \"#{parent_type}\""

    unless facet_conditions.empty?
      #unfortunately have to do subselect here to get this correct
      conditions = "#{Atrium::BrowsePage::FacetSelection.quoted_table_name}.`atrium_browse_page_id` in (select #{Atrium::BrowsePage::FacetSelection.quoted_table_name}.`atrium_browse_page_id`
from #{Atrium::BrowsePage::FacetSelection.quoted_table_name} INNER JOIN #{quoted_table_name} ON #{Atrium::BrowsePage::FacetSelection.quoted_table_name}.`atrium_browse_page_id` = #{quoted_table_name}.`id`
where #{quoted_table_name}.browse_pages_id = #{parent_id} AND #{quoted_table_name}.`browse_pages_type` = \"#{parent_type}\" AND (#{facet_conditions.join(" OR ")}))"
      having_str = "count(#{Atrium::BrowsePage::FacetSelection.quoted_table_name}.`atrium_browse_page_id`) = #{facet_conditions.size}"
      joins("INNER JOIN #{Atrium::BrowsePage::FacetSelection.quoted_table_name} ON #{Atrium::BrowsePage::FacetSelection.quoted_table_name}.`atrium_browse_page_id` = #{quoted_table_name}.`id`").
          where(conditions).group("#{Atrium::BrowsePage::FacetSelection.quoted_table_name}.`atrium_browse_page_id`").having(having_str)
    else
      conditions = "#{conditions} AND #{Atrium::BrowsePage::FacetSelection.quoted_table_name}.`id` is NULL"
      joins("LEFT OUTER JOIN #{Atrium::BrowsePage::FacetSelection.quoted_table_name} ON #{quoted_table_name}.`id` = #{Atrium::BrowsePage::FacetSelection.quoted_table_name}.`atrium_browse_page_id`").where(conditions)
    end
  }

end
