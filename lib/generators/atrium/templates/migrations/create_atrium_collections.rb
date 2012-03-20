class CreateAtriumCollections < ActiveRecord::Migration
  def self.up
    create_table :atrium_collections do |t|
      t.string :title
      t.string :filter_query_params
      t.string :theme
      t.text :collection_description
      t.text :collection_items
    end
    add_index :atrium_collections, :id
  end

  def self.down
    drop_table :atrium_collections
  end
end
