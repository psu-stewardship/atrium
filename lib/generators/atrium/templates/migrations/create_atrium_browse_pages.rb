class CreateAtriumBrowsePages < ActiveRecord::Migration
  def self.up
    create_table :atrium_browse_pages do |t|
      t.text :browse_page_items
      #t.integer :atrium_parent_id
      #t.string  :atrium_parent_type
      t.references :browse_pages,  :polymorphic=>true
    end
    add_index :atrium_browse_pages, :id
    #add_index :atrium_browse_pages, :atrium_parent_id, :atrium_parent_type
  end

  def self.down
    drop_table :atrium_browse_pages
  end
end
