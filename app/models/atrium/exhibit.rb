class Atrium::Exhibit < ActiveRecord::Base
  has_many :showcases,     :class_name=>'Atrium::Showcase',      :foreign_key=>'atrium_exhibit_id', :order=>'set_number ASC', :dependent => :destroy
  has_many :search_facets, :class_name=>'Atrium::Search::Facet', :foreign_key=>'atrium_exhibit_id', :dependent => :destroy

  accepts_nested_attributes_for :showcases,     :allow_destroy => true
  accepts_nested_attributes_for :search_facets, :allow_destroy => true

  set_table_name :atrium_exhibits

  serialize :filter_query_params

  def search_facet_names
    search_facets.map{|facet| facet.name }
  end

  def search_facet_names=(collection_of_facet_names)
    existing_facet_names = search_facets.map{|facet| facet.name }
    add_collection_of_facets_by_name( collection_of_facet_names - existing_facet_names )
    remove_collection_of_facets_by_name( existing_facet_names - collection_of_facet_names )
  end

  private

  def add_collection_of_facets_by_name(collection_of_facet_names)
    collection_of_facet_names.each do |name|
      search_facets << Atrium::Search::Facet.find_or_create_by_name_and_exhibit_id(name, id)
    end
  end

  def remove_collection_of_facets_by_name(collection_of_facet_names)
    collection_of_facet_names.each do |name|
      search_facets.delete(Atrium::Search::Facet.find_by_name_and_exhibit_id(name, id))
    end
  end

end
