class Atrium::Showcase < ActiveRecord::Base
  has_many :browse_levels, :class_name => 'Atrium::BrowseLevel', :foreign_key => 'atrium_showcase_id', :order => 'level_number ASC'
  has_many :browse_pages,  :class_name => 'Atrium::BrowsePage',  :foreign_key => 'atrium_showcase_id'

  accepts_nested_attributes_for :browse_levels, :allow_destroy=>true
  accepts_nested_attributes_for :browse_pages

  set_table_name :atrium_showcases

  def title
    label.blank? ? "Showcase #{set_number}" : label
  end

  def browse_facet_names
    browse_levels.collect {|facet| facet.solr_facet_name} rescue []
  end
end
