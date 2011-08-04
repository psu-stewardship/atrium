class Atrium::Filter::Facet < ActiveRecord::Base
  belongs_to :exhibit, :class_name=>'Atrium::Exhibit', :foreign_key=>"atrium_exhibit_id"

  validates_presence_of :atrium_exhibit_id

  set_table_name :atrium_filter_facets
end
