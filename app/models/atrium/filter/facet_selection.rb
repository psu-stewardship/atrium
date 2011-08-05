class Atrium::Filter::FacetSelection < ActiveRecord::Base
  belongs_to :showcase, :class_name=>'Atrium::Showcase', :foreign_key=>"atrium_showcase_id"
  belongs_to :facet, :class_name=>'Atrium::Filter::Facet', :foreign_key=>"atrium_filter_facet_id"

  validates_presence_of :atrium_showcase_id, :atrium_filter_facet_id

  set_table_name :atrium_filter_facet_selections

  def value
    value = super
    value.nil? ? "" : value
  end
end
