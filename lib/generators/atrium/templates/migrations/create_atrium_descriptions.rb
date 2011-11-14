class CreateAtriumDescriptions < ActiveRecord::Migration
  def self.up
    create_table :atrium_descriptions do |t|
      t.integer :atrium_browse_page_id, :null=>false
      t.string :solr_doc_id
      t.text :description
    end
    add_index :atrium_descriptions, :id
    add_index :atrium_descriptions, :atrium_browse_page_id
  end

  def self.down
    drop_table :atrium_descriptions
  end
end
