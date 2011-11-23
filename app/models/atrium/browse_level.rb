class Atrium::BrowseLevel < ActiveRecord::Base
  belongs_to :exhibit, :class_name=>'Atrium::Exhibit', :foreign_key=>"atrium_exhibit_id"

  validates_presence_of :atrium_exhibit_id, :level_number, :solr_facet_name

  set_table_name :atrium_browse_levels

  serialize :filter_query_params

  attr_accessor :values, :selected

  def values
    @values ||= []
  end

end
