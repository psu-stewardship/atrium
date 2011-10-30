class Atrium::BrowsePage < ActiveRecord::Base
  has_many :featured_items, :class_name=>'Atrium::BrowsePage::Item::Featured', :foreign_key=>"atrium_browse_page_id"
  has_many :related_items, :class_name=>'Atrium::BrowsePage::Item::Related', :foreign_key=>"atrium_browse_page_id"
  has_many :descriptions, :class_name=>'Atrium::BrowsePage::Item::Description', :foreign_key=>"atrium_browse_page_id"
  belongs_to :showcase, :class_name=>'Atrium::Showcase', :foreign_key=>"atrium_showcase_id"
  has_many :facet_selections, :class_name=>'Atrium::BrowsePage::FacetSelection', :foreign_key=>"atrium_browse_page_id"

  validates_presence_of :atrium_showcase_id

  serialize :browse_page_items, Hash

  accepts_nested_attributes_for :featured_items, :allow_destroy=>true
  accepts_nested_attributes_for :related_items, :allow_destroy=>true
  accepts_nested_attributes_for :descriptions, :allow_destroy=>true
  accepts_nested_attributes_for :facet_selections

  set_table_name :atrium_browse_pages

  def initialize(opts={})
    super
    #facet
  end

  def browse_page_items
    read_attribute(:browse_page_items) || write_attribute(:browse_page_items, {})
  end

  def type
    browse_page_items[:type] unless browse_page_items.blank?
  end

  def solr_doc_ids
    browse_page_items[:solr_doc_ids]  unless browse_page_items.blank?
  end

  def with_selected_facets
  end

end
