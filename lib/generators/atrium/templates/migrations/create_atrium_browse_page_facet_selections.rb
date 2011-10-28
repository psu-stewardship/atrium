class CreateAtriumBrowsePageFacetSelections < ActiveRecord::Migration
  def self.up
    create_table :atrium_browse_page_facet_selections do |t|
      t.integer :atrium_browse_page_id
      t.string :solr_facet_name
      t.string :value
    end
    add_index :atrium_browse_page_facet_selections, :id
    add_index :atrium_browse_page_facet_selections, :atrium_browse_page_id, :name =>'atrium_facet_browse_page_index'
  end

  def self.down
    drop_table :atrium_browse_page_facet_selections
  end
end
