class Atrium::Search::Facet < ActiveRecord::Base
  belongs_to :exhibit, :class_name=>'Atrium::Exhibit', :foreign_key=>"atrium_exhibit_id"

  validates_presence_of :atrium_exhibit_id, :name

  set_table_name :atrium_search_facets

  scope :find_by_name_and_exhibit_id, lambda {|name, exhibit_id|
    where("#{self.quoted_table_name}.`name` = ? AND #{self.quoted_table_name}.`atrium_exhibit_id` = ?", name, exhibit_id)
  }

  def self.find_or_create_by_name_and_exhibit_id(name, exhibit_id)
    exsiting_facets = self.find_by_name_and_exhibit_id(name, exhibit_id)
    exsiting_facets.any? ? exsiting_facets.first : self.create(:name => name, :atrium_exhibit_id => id)
  end

end
