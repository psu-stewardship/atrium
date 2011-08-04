class CreateAtriumShowcases < ActiveRecord::Migration
  def self.up
    create_table :atrium_showcases do |t|
      t.integer :atrium_exhibit_id
    end
    add_index :atrium_showcases, :id
    add_index :atrium_showcases, :atrium_exhibit_id
  end

  def self.down
    drop_table :atrium_showcases
  end
end
