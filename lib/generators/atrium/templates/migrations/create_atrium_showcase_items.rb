class CreateAtriumShowcaseItems < ActiveRecord::Migration
  def self.up
    create_table :atrium_showcase_items do |t|
      t.string :solr_doc_id, :null=>false
      t.string :type
      t.integer :atrium_showcase_id, :null=>false
    end

    add_index :atrium_showcase_items, :solr_doc_id
    add_index :atrium_showcase_items, :id
    add_index :atrium_showcase_items, :atrium_showcase_id
  end

  def self.down
    drop_table :atrium_showcase_items
  end
end
