class Atrium::Search::Facet < ActiveRecord::Base
  belongs_to :exhibit, :class_name=>'Atrium::Exhibit', :foreign_key=>"atrium_exhibit_id"

  validates_presence_of :atrium_exhibit_id, :name

  set_table_name :atrium_search_facets

  def name
    name = super
    name.nil? ? "" : name
  end
end
