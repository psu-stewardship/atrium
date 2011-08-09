class CreateAtriumExhibits < ActiveRecord::Migration
  def self.up
    create_table :atrium_exhibits do |t|
      t.string :title
      t.string :solr_filter_query
      t.string :solr_top_browse_level_query
    end
    add_index :atrium_exhibits, :id
  end

  def self.down
    drop_table :atrium_exhibits
  end
end
