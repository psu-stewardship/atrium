class Atrium::Item < ActiveRecord::Base
  belongs_to :showcase, :class_name=>'Atrium::Showcase', :foreign_key=>"atrium_showcase_id"

  validates_presence_of :solr_doc_id, :atrium_showcase_id

  set_table_name :atrium_items
end
