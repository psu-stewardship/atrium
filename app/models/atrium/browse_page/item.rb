class Atrium::BrowsePage::Item < ActiveRecord::Base
  belongs_to :browse_page, :class_name=>'Atrium::BrowsePage', :foreign_key=>"atrium_browse_page_id"

  validates_presence_of :solr_doc_id, :atrium_browse_page_id

  set_table_name :atrium_browse_page_items
end
