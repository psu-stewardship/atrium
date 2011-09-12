class Atrium::BrowseSet < ActiveRecord::Base
  has_many :browse_levels, :class_name=>'Atrium::BrowseLevel', :foreign_key=>"atrium_browse_set_id", :order=>'level_number ASC'
  has_many :showcases, :class_name=>'Atrium::Showcase', :foreign_key=>"atrium_browse_set_id"

  accepts_nested_attributes_for :browse_levels, :allow_destroy=>true
  accepts_nested_attributes_for :showcases

  set_table_name :atrium_browse_sets

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
