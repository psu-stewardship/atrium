class Atrium::Showcase < ActiveRecord::Base
  has_many :featured_items, :class_name=>'Atrium::Item::Featured', :foreign_key=>"atrium_item_id"
  has_many :related_items, :class_name=>'Atrium::Item::Related', :foreign_key=>"atrium_item_id"
  has_many :descriptions, :class_name=>'Atrium::Item::Description', :foreign_key=>"atrium_item_id"
  belongs_to :exhibit, :class_name=>'Atrium::Exhibit', :foreign_key=>"atrium_exhibit_id"
  has_many :facet_selections, :class_name=>'Atrium::Filter::FacetSelection', :foreign_key=>"atrium_filter_facet_selection_id"
  has_many :facets, :through=>:facet_selections, :class_name=>'Atrium::Filter::Facet', :foreign_key=>"atrium_filter_facet_id"

  set_table_name :atrium_showcases
end
