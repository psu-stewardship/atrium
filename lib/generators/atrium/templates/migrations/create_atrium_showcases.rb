class CreateAtriumShowcases < ActiveRecord::Migration
  def self.up
    create_table :atrium_showcases do |t|
      t.integer :atrium_exhibit_id, :null=>false
      t.integer :set_number, :null=>false
      t.string :label
      t.string :solr_filter_query
    end
    add_index :atrium_showcases, :id
    add_index :atrium_showcases, :atrium_exhibit_id
  end

  def self.down
    drop_table :atrium_showcases
  end
end
