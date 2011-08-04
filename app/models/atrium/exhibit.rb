class Atrium::Exhibit < ActiveRecord::Base
  has_many :queries, :class_name=>'Atrium::Filter::Query', :foreign_key=>"atrium_exhibit_id"
  has_many :browse_facets, :class_name=>'Atrium::Filter::Facet::BrowseFacet', :foreign_key=>"atrium_exhibit_id"
  has_many :search_facets, :class_name=>'Atrium::Filter::Facet::SearchFacet', :foreign_key=>"atrium_exhibit_id"
  has_many :showcases, :class_name=>'Atrium::Showcase', :foreign_key=>"atrium_exhibit_id"

  accepts_nested_attributes_for :queries
  accepts_nested_attributes_for :browse_facets, :allow_destroy=>true
  accepts_nested_attributes_for :search_facets, :allow_destroy=>true
  accepts_nested_attributes_for :showcases

  set_table_name :atrium_exhibits

  def title
    title = super
    title.nil? ? "" : title
  end

  def build_members_query
    q = ""
    field_queries = []
    unless queries.empty?
      queries.each do |query|
        field_queries << "_query_:\"#{query.value}\"" unless query.value.nil? || query.value.empty?
      end
      q << "#{field_queries.join(" AND ")}"
    end
    q
  end

  def browse_facet_names
    names = []
    names = browse_facets.collect {|x| x.name} unless browse_facets.nil? || browse_facets.empty?
    names
  end
end
