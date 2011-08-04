class CreateAtriumFilterFacetSelections < ActiveRecord::Migration
  def self.up
    create_table :atrium_filter_facet_selections do |t|
      t.integer :atrium_filter_facet_id
      t.integer :atrium_showcase_id
      t.string :value
    end
    add_index :atrium_filter_facet_selections, :atrium_filter_facet_id
    add_index :atrium_filter_facet_selections, :atrium_showcase_id
    #commented out for now because index produced is too long of a name
    #add_index :atrium_filter_facet_selections, [:atrium_filter_facet_id,:atrium_showcase_id]
  end

  def self.down
    drop_table :atrium_filter_facet_selections
  end
end
