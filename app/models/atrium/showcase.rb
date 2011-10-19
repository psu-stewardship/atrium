class Atrium::Showcase < ActiveRecord::Base
  has_many :browse_levels, :class_name=>'Atrium::BrowseLevel', :foreign_key=>"atrium_showcase_id", :order=>'level_number ASC'
  has_many :browse_pages, :class_name=>'Atrium::BrowsePage', :foreign_key=>"atrium_showcase_id"

  accepts_nested_attributes_for :browse_levels, :allow_destroy=>true
  accepts_nested_attributes_for :browse_pages

  set_table_name :atrium_showcases

  def label
    label = super
    label.nil? ? "" : label
  end

  def browse_facet_names
    names = []
    names = browse_levels.collect {|x| x.solr_facet_name} unless browse_levels.nil? || browse_levels.empty?
    names
  end
end
