class CreateAtriumShowcases < ActiveRecord::Migration
  def self.up
    create_table :atrium_showcases do |t|
      t.text :showcase_items
      #t.integer :atrium_parent_id
      #t.string  :atrium_parent_type
      t.references :showcases,  :polymorphic=>true
    end
    add_index :atrium_showcases, :id
    #add_index :atrium_showcases, :atrium_parent_id, :atrium_parent_type
  end

  def self.down
    drop_table :atrium_showcases
  end
end
