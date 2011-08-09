class Atrium::Exhibit < ActiveRecord::Base
  has_many :browse_levels, :class_name=>'Atrium::BrowseLevel', :foreign_key=>"atrium_exhibit_id", :order=>'level_number ASC'
  has_many :search_facets, :class_name=>'Atrium::Search::Facet', :foreign_key=>"atrium_exhibit_id"
  has_many :showcases, :class_name=>'Atrium::Showcase', :foreign_key=>"atrium_exhibit_id"

  accepts_nested_attributes_for :browse_levels, :allow_destroy=>true
  accepts_nested_attributes_for :search_facets, :allow_destroy=>true
  accepts_nested_attributes_for :showcases

  set_table_name :atrium_exhibits

  def title
    title = super
    title.nil? ? "" : title
  end

  def build_members_query
    (solr_filter_query.nil? || solr_filter_query.empty?) ? "" : "_query_:\"#{solr_filter_query}\"" 
  end

  def browse_facet_names
    names = []
    names = browse_levels.collect {|x| x.solr_facet_name} unless browse_levels.nil? || browse_levels.empty?
    names
  end
end
