class Atrium::Exhibit < ActiveRecord::Base
  has_many :browse_levels, :class_name => 'Atrium::BrowseLevel', :foreign_key => 'atrium_exhibit_id', :order => 'level_number ASC'
  has_many :showcases,  :class_name => 'Atrium::Showcase',  :as=>:showcases
  belongs_to :collection, :class_name => 'Atrium::Collection', :foreign_key => 'atrium_collection_id'

  accepts_nested_attributes_for :browse_levels, :allow_destroy=>true
  accepts_nested_attributes_for :showcases

  set_table_name :atrium_exhibits

  serialize :filter_query_params

  def title
    label.blank? ? "Exhibit #{set_number}" : label
  end

  def browse_facet_names
    browse_levels.collect {|facet| facet.solr_facet_name} rescue []
  end

  def facet_order
    facet_order = {}
    browse_levels.map{|facet| facet_order[facet.id] = facet.level_number }
    facet_order
  end

  def facet_order=(facet_order = {})
    valid_ids = browse_levels.select(:id).map{|facet| facet.id}
    facet_order.each_pair do |id, order|
      Atrium::BrowseLevel.find(id).update_attributes!(:level_number => order) if valid_ids.include?(id.to_i)
    end
  end
end
