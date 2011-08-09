class CreateAtriumSearchFacets < ActiveRecord::Migration
  def self.up
    create_table :atrium_search_facets do |t|
      t.integer :atrium_exhibit_id, :null=>false
      t.string :name
    end
    add_index :atrium_search_facets, :id
    add_index :atrium_search_facets, :atrium_exhibit_id
  end

  def self.down
    drop_table :atrium_search_facets
  end
end
