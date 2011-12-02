class Atrium::Showcase::Item < ActiveRecord::Base
  set_table_name :atrium_showcase_items

  belongs_to :showcase, :class_name => 'Atrium::Showcase', :foreign_key => 'atrium_showcase_id'

  validates_presence_of :solr_doc_id, :atrium_showcase_id

end
