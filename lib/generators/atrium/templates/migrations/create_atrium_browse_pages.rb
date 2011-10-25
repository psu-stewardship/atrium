class CreateAtriumBrowsePages < ActiveRecord::Migration
  def self.up
    create_table :atrium_browse_pages do |t|
      t.integer :atrium_browse_page_id
      t.integer :atrium_showcase_id
      t.text :browse_page_items
    end
    add_index :atrium_browse_pages, :id
    add_index :atrium_browse_pages, :atrium_showcase_id
  end

  def self.down
    drop_table :atrium_browse_pages
  end
end
