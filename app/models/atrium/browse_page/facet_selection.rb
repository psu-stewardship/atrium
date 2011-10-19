class Atrium::BrowsePage::FacetSelection < ActiveRecord::Base
  belongs_to :browse_page, :class_name=>'Atrium::BrowsePage', :foreign_key=>"atrium_browse_page_id"

  validates_presence_of :atrium_browse_page_id, :value, :solr_facet_name

  set_table_name :atrium_browse_page_facet_selections
end
