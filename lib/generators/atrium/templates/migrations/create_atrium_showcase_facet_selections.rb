class CreateAtriumShowcaseFacetSelections < ActiveRecord::Migration
  def self.up
    create_table :atrium_showcase_facet_selections do |t|
      t.integer :atrium_showcase_id
      t.string :solr_facet_name
      t.string :value
    end
    add_index :atrium_showcase_facet_selections, :id
    add_index :atrium_showcase_facet_selections, :atrium_showcase_id, :name =>'atrium_facet_showcase_index'
  end

  def self.down
    drop_table :atrium_showcase_facet_selections
  end
end
