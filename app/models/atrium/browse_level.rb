class Atrium::BrowseLevel < ActiveRecord::Base
  set_table_name :atrium_browse_levels

  belongs_to :exhibit, :class_name => 'Atrium::Exhibit', :foreign_key => 'atrium_exhibit_id'

  validates_presence_of :atrium_exhibit_id, :level_number, :solr_facet_name

  serialize :filter_query_params

  attr_accessor :values, :selected

  def values
    @values ||= []
  end

end
