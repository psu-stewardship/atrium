class CreateAtriumBrowseSets < ActiveRecord::Migration
  def self.up
    create_table :atrium_browse_sets do |t|
      t.integer :atrium_exhibit_id, :null=>false
      t.integer :set_number, :null=>false
      t.string :label
      t.string :solr_filter_query
    end
    add_index :atrium_browse_sets, :id
    add_index :atrium_browse_sets, :atrium_exhibit_id
  end

  def self.down
    drop_table :atrium_browse_sets
  end
end
