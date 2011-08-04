class CreateAtriumFilterQueries < ActiveRecord::Migration
  def self.up
    create_table :atrium_filter_queries do |t|
      t.integer :atrium_exhibit_id
      t.string :value
    end
    add_index :atrium_filter_queries, :id
    add_index :atrium_filter_queries, :atrium_exhibit_id
  end

  def self.down
    drop_table :atrium_filter_queries
  end
end
