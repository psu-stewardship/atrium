class CreateAtriumFilterFacets < ActiveRecord::Migration
  def self.up
    create_table :atrium_filter_facets do |t|
      t.string :type
      t.integer :atrium_exhibit_id, :null=>false
      t.string :name
    end
    add_index :atrium_filter_facets, :id
    add_index :atrium_filter_facets, :atrium_exhibit_id
  end

  def self.down
    drop_table :atrium_filter_facets
  end
end
