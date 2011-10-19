class Atrium::BrowseLevel < ActiveRecord::Base
  belongs_to :showcase, :class_name=>'Atrium::Showcase', :foreign_key=>"atrium_showcase_id"

  validates_presence_of :atrium_showcase_id, :level_number, :solr_facet_name

  set_table_name :atrium_browse_levels

  attr_accessor :values, :selected

  def values
    @values ||= []
  end

end
