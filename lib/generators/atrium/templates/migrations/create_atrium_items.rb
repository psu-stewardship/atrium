class CreateAtriumItems < ActiveRecord::Migration
  def self.up
    create_table :atrium_items do |t|
      t.string :type
      t.integer :atrium_showcase_id, :null=>false
    end

    add_index :atrium_items, :id
    add_index :atrium_items, :atrium_showcase_id
  end

  def self.down
    drop_table :atrium_items
  end
end
