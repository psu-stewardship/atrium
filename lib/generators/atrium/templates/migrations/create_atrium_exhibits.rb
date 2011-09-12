class CreateAtriumExhibits < ActiveRecord::Migration
  def self.up
    create_table :atrium_exhibits do |t|
      t.string :title
      t.string :solr_filter_query
    end
    add_index :atrium_exhibits, :id
  end

  def self.down
    drop_table :atrium_exhibits
  end
end
