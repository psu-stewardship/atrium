class Atrium::BrowseLevel < ActiveRecord::Base
  belongs_to :browse_set, :class_name=>'Atrium::BrowseSet', :foreign_key=>"atrium_browse_set_id"

  validates_presence_of :atrium_browse_set_id, :level_number, :solr_facet_name

  set_table_name :atrium_browse_levels

  attr_accessor :values, :selected

  def values
    @values ||= []
  end

end
