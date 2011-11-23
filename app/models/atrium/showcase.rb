class Atrium::Showcase < ActiveRecord::Base
  has_many :featured_items, :class_name=>'Atrium::Showcase::Item::Featured', :foreign_key=>"atrium_showcase_id"
  has_many :related_items, :class_name=>'Atrium::Showcase::Item::Related', :foreign_key=>"atrium_showcase_id"
  has_many :descriptions, :class_name=>'Atrium::Description', :foreign_key=>"atrium_showcase_id" , :dependent => :destroy

  #belongs_to :exhibit, :class_name=>'Atrium::Exhibit', :foreign_key=>"atrium_exhibit_id"
  belongs_to :showcases, :polymorphic => true
  has_many :facet_selections, :class_name=>'Atrium::Showcase::FacetSelection', :foreign_key=>"atrium_showcase_id"

  #validates_presence_of :atrium_exhibit_id

  serialize :showcase_items, Hash

  accepts_nested_attributes_for :featured_items, :allow_destroy=>true
  accepts_nested_attributes_for :related_items, :allow_destroy=>true
  accepts_nested_attributes_for :descriptions, :allow_destroy=>true
  accepts_nested_attributes_for :facet_selections

  set_table_name :atrium_showcases

  def initialize(opts={})
    super
    #facet
  end

  def showcase_items
    read_attribute(:showcase_items) || write_attribute(:showcase_items, {})
  end


  def type
    showcase_items[:type] unless showcase_items.blank?
  end


  def solr_doc_ids
    showcase_items[:solr_doc_ids]  unless showcase_items.blank?
  end
   #this method will select showcase objects that have exactly the selected facets passed in (but no more or no less) and is tied to the given exhibit id
  #it expects two parameters:
  # @param[String] the exhibit id
  # @param[Hash] hash of key value pairs of selected facets
  # @return Array of showcase objects found
  scope :with_selected_facets, lambda {|*args|
    parent_id, parent_type, selected_facets = args.flatten(1)
    logger.debug("getting browse page for exhibit: #{parent_id.inspect}, type:#{parent_type} and facets: #{selected_facets.inspect}")

    selected_facets ? facet_conditions = selected_facets.collect {|key,value| "(#{Atrium::Showcase::FacetSelection.quoted_table_name}.`solr_facet_name` = '#{key}' and #{Atrium::Showcase::FacetSelection.quoted_table_name}.`value` = '#{(value.is_a?(String) ? value : value.flatten)}')"} : facet_conditions = {}
    conditions = "#{quoted_table_name}.`showcases_id` = #{parent_id} AND #{quoted_table_name}.`showcases_type` = \"#{parent_type}\""

    unless facet_conditions.empty?
      #unfortunately have to do subselect here to get this correct
      conditions = "#{Atrium::Showcase::FacetSelection.quoted_table_name}.`atrium_showcase_id` in (select #{Atrium::Showcase::FacetSelection.quoted_table_name}.`atrium_showcase_id`
from #{Atrium::Showcase::FacetSelection.quoted_table_name} INNER JOIN #{quoted_table_name} ON #{Atrium::Showcase::FacetSelection.quoted_table_name}.`atrium_showcase_id` = #{quoted_table_name}.`id`
where #{quoted_table_name}.showcases_id = #{parent_id} AND #{quoted_table_name}.`showcases_type` = \"#{parent_type}\" AND (#{facet_conditions.join(" OR ")}))"
      having_str = "count(#{Atrium::Showcase::FacetSelection.quoted_table_name}.`atrium_showcase_id`) = #{facet_conditions.size}"
      joins("INNER JOIN #{Atrium::Showcase::FacetSelection.quoted_table_name} ON #{Atrium::Showcase::FacetSelection.quoted_table_name}.`atrium_showcase_id` = #{quoted_table_name}.`id`").
          where(conditions).group("#{Atrium::Showcase::FacetSelection.quoted_table_name}.`atrium_showcase_id`").having(having_str)
    else
      conditions = "#{conditions} AND #{Atrium::Showcase::FacetSelection.quoted_table_name}.`id` is NULL"
      joins("LEFT OUTER JOIN #{Atrium::Showcase::FacetSelection.quoted_table_name} ON #{quoted_table_name}.`id` = #{Atrium::Showcase::FacetSelection.quoted_table_name}.`atrium_showcase_id`").where(conditions)
    end
  }

end
