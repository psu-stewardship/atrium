class CreateAtriumShowcases < ActiveRecord::Migration
  def self.up
    create_table :atrium_showcases do |t|
      t.integer :atrium_collection_id, :null=>false
      t.integer :set_number, :null=>false
      t.string :label
      t.string :filter_query_params
    end
    add_index :atrium_showcases, :id
    add_index :atrium_showcases, :atrium_collection_id
  end

  def self.down
    drop_table :atrium_showcases
  end
end
