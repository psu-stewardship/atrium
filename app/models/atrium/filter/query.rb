class Atrium::Filter::Query < ActiveRecord::Base
  belongs_to :atrium_exhibit, :class_name=>'Atrium::Exhibit', :foreign_key=>"atrium_exhibit_id"

  set_table_name :atrium_filter_queries
end
