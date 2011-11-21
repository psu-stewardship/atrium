class Atrium::Search::Facet < ActiveRecord::Base
  belongs_to :collection, :class_name=>'Atrium::Collection', :foreign_key=>"atrium_collection_id"

  validates_presence_of :atrium_collection_id, :name

  set_table_name :atrium_search_facets

  scope :find_by_name_and_collection_id, lambda {|name, collection_id|
    where("#{self.quoted_table_name}.`name` = ? AND #{self.quoted_table_name}.`atrium_collection_id` = ?", name, collection_id)
  }

  def self.find_or_create_by_name_and_collection_id(name, collection_id)
    exsiting_facets = self.find_by_name_and_collection_id(name, collection_id)
    exsiting_facets.any? ? exsiting_facets.first : self.create(:name => name, :atrium_collection_id => id)
  end

end
