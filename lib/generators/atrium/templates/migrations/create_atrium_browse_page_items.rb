class CreateAtriumBrowsePageItems < ActiveRecord::Migration
  def self.up
    create_table :atrium_browse_page_items do |t|
      t.string :solr_doc_id, :null=>false
      t.string :type
      t.integer :atrium_browse_page_id, :null=>false
    end

    add_index :atrium_browse_page_items, :solr_doc_id
    add_index :atrium_browse_page_items, :id
    add_index :atrium_browse_page_items, :atrium_browse_page_id
  end

  def self.down
    drop_table :atrium_browse_page_items
  end
end
